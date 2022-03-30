# Microsoft SQL Server Docker image

Unofficial images for Microsoft SQL Server on Linux for Docker Engine.

In comparison to the [official image](https://hub.docker.com/_/microsoft-mssql-server) this image supports multimple build modes.

&nbsp;

# Build args

Supported arguments from SQL Server installer, see [here](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-ver15)

Important build arguments:

| Argument                  | Description
| ------------------------- | -------------------------
| ACCEPT_EULA               | Set the ACCEPT_EULA variable to any value to confirm your acceptance of the [End-User Licensing Agreement](https://go.microsoft.com/fwlink/?LinkId=746388). Required setting for the SQL Server image.
| MSSQL_SA_PASSWORD         | 	Configure the SA user password.
| MSSQL_PID                 | Set the SQL Server edition or product key. Possible values include:<br/>**Evaluation<br/>Developer<br/>Express<br/>Web<br/>Standard<br/>Enterprise<br/>A product key**<br/><br/>If specifying a product key, it must be in the form of #####-#####-#####-#####-#####, where '#' is a number or a letter.
| MSSQL_MEMORY_LIMIT_MB     | Sets the maximum amount of memory (in MB) that SQL Server can use. By default it is 80% of the total physical memory.

In addition, the following build args are available:

| Argument                    | Description
| --------------------------- | -------------------------
| SQL_INSTALL_TOOLS           | Install SQL Server Tools. Package `mssq-tools` (recommended).
| SQL_INSTALL_AGENT           | Install SQL Server Agent (recommended). Package `mssql-server-agent`
| SQL_INSTALL_FULLTEXT        | Install SQL Server Full Text Search (optional). Package `mssql-server-fts`
| SQL_INSTALL_POLYBASE        | Install SQL Server Polybase extension. Package `mssql-server-polybase`
| SQL_INSTALL_POLYBASE_HADOOP | Install SQL Server Polybase Hadoop extension. Package `mssql-server-polybase-hadoop` with the missing package `mssql-zulu-jre-*.deb`

&nbsp;

# Environment variables

| Argument         | Description
| ---------------- | -------------------------
| ACCEPT_EULA      | Set the ACCEPT_EULA variable to any value to confirm your acceptance of the [End-User Licensing Agreement](https://go.microsoft.com/fwlink/?LinkId=746388). Required setting for the SQL Server image.
| MSSQL_USER       | Create an additional user with sysadmin privileges (optional). This requires `SQL_INSTALL_TOOLS` to be set.
| MSSQL_PASSWORD   | Create an additional user with sysadmin privileges (optional). This requires `SQL_INSTALL_TOOLS` to be set.
| MSSQL_DATABASE   | Creates an database in recovery mode SIMPLE. This requires `SQL_INSTALL_TOOLS` to be set.


# Sample build guide

## Minimal build

``` shell
docker build -t mssql \
    --build-arg ACCEPT_EULA=y
```

## Build with recommended settings

``` shell
docker build -t mssql \
    --build-arg ACCEPT_EULA=y \
    --build-arg MSSQL_PID='Developer' \
    --build-arg MSSQL_SA_PASSWORD='<YourStrong!Passw0rd>'
    --build-arg SQL_INSTALL_TOOLS=1
```

### Sample build with Polybase

``` shell
docker build . -t mssql \
    --build-arg ACCEPT_EULA=y \
    --build-arg MSSQL_PID='Developer' \
    --build-arg MSSQL_SA_PASSWORD='<YourStrong!Passw0rd>' \
    --build-arg SQL_INSTALL_TOOLS=1 \
    --build-arg SQL_INSTALL_POLYBASE=1
```

### Sample build with custom user and database

``` shell
docker build . -t mssql \
    --build-arg ACCEPT_EULA=y \
    --build-arg MSSQL_PID='Developer' \
    --build-arg SQL_INSTALL_TOOLS=1 \
    --build-arg SQL_INSTALL_USER=MySysAdminUser \
    --build-arg SQL_INSTALL_USER_PASSWORD=my!Se3u8e$Passw0rd \
    --build-arg SQL_INSTALL_DATABASE=UserDatabase
```

# Starting the image

You need to provide the `ACCEPT_EULA` environment variable when starting the image:
``` shell
docker run -e 'ACCEPT_EULA=y' mssql
```

&nbsp;

# License

The docker file is released under the [MIT](LICENSE) license.

For Microsoft SQL Server, please have a look at the Microsoft [End-User Licensing Agreement](https://go.microsoft.com/fwlink/?LinkId=746388).
