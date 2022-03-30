FROM ubuntu:20.04

USER root

# Install prerequistes including repo config for SQL server and PolyBase.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg

# Get official Microsoft repository configuration
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    echo "deb [arch=amd64,armhf,arm64] https://packages.microsoft.com/ubuntu/20.04/prod focal main" >> /etc/apt/sources.list && \
    echo "deb [arch=amd64,armhf,arm64] https://packages.microsoft.com/ubuntu/20.04/mssql-server-2019 focal main" >> /etc/apt/sources.list

# Info: https://docs.microsoft.com/en-us/sql/linux/sample-unattended-install-ubuntu?view=sql-server-ver15

ARG SQL_INSTALL_TOOLS
ARG SQL_INSTALL_AGENT
ARG SQL_INSTALL_FULLTEXT
ARG SQL_INSTALL_POLYBASE
ARG SQL_INSTALL_POLYBASE_HADOOP

## Get missing package for polybase-hadoop
RUN if [ ! -z ${SQL_INSTALL_POLYBASE_HADOOP} ]; \
    then \
        curl https://packages.microsoft.com/ubuntu/20.04/prod/pool/main/m/mssql-zulu-jre-11/mssql-zulu-jre-11_11.43.56-1_amd64.deb -O mssql-zulu-jre-11_11.43.56-1_amd64.deb; \
        apt install -y ./mssql-zulu-jre-11_11.43.56-1_amd64.deb; \
        rm ./mssql-zulu-jre-11_11.43.56-1_amd64.deb; \
    fi

ARG ACCEPT_EULA
RUN apt-get update && \
    ACCEPT_EULA=${ACCEPT_EULA} DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    mssql-server \
    ${SQL_INSTALL_TOOLS:+mssql-tools} ${SQL_INSTALL_TOOLS:+unixodbc-dev} \
    ${SQL_INSTALL_AGENT:+mssql-server-agent} \
    ${SQL_INSTALL_FULLTEXT:+mssql-server-fts} \
    ${SQL_INSTALL_POLYBASE:+mssql-server-polybase} \
    ${SQL_INSTALL_POLYBASE_HADOOP:+mssql-server-polybase-hadoop}

# Cleanup the Dockerfile
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists

ARG MSSQL_SA_PASSWORD=YourStrong@Passw0rd
ENV MSSQL_SA_PASSWORD ${MSSQL_SA_PASSWORD}

ENV SQL_INSTALL_POLYBASE ${SQL_INSTALL_POLYBASE}

CMD if [ -f /opt/mssql-tools/bin/sqlcmd ]; \
    then \
        /opt/mssql/bin/sqlservr & sleep 20 \
            && if [ ! -z $SQL_INSTALL_POLYBASE ]; then \
                echo "Enable Polybase ..."; \
                /opt/mssql-tools/bin/sqlcmd -S localhost -U sa \
                    -P "${MSSQL_SA_PASSWORD}" \
                    -Q "EXEC sp_configure @configname = 'polybase enabled', @configvalue = 1;\
RECONFIGURE WITH OVERRIDE;"; \
                fi \
            && if [ ! -z $MSSQL_DATABASE ]; then \
                echo "Create database $MSSQL_DATABASE ..."; \
                /opt/mssql-tools/bin/sqlcmd -S localhost -U sa \
                    -P "${MSSQL_SA_PASSWORD}" \
                    -Q "CREATE DATABASE [$MSSQL_DATABASE];";\
                /opt/mssql-tools/bin/sqlcmd -S localhost -U sa \
                    -P "${MSSQL_SA_PASSWORD}" \
                    -Q "ALTER DATABASE [$MSSQL_DATABASE] SET RECOVERY SIMPLE";\
                fi \
            && if [ ! -z $MSSQL_USER ] && [ ! -z $MSSQL_PASSWORD ]; then \
                echo "Create user $MSSQL_USER ..."; \
                /opt/mssql-tools/bin/sqlcmd -S localhost -U sa \
                    -P "${MSSQL_SA_PASSWORD}" \
                    -Q "CREATE LOGIN [$MSSQL_USER] WITH PASSWORD=N'$MSSQL_PASSWORD', DEFAULT_DATABASE=[${MSSQL_DATABASE:-master}], CHECK_EXPIRATION=ON, CHECK_POLICY=ON; ALTER SERVER ROLE [sysadmin] ADD MEMBER [$MSSQL_USER]"; \
                fi &\
        wait;\
    else \
        # Run the sqlserver instance without any interaction
        /opt/mssql/bin/sqlservr;\
    fi