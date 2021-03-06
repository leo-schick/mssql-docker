# Microsoft SQL Server Docker image

Unofficial images for [Microsoft SQL Server](http://www.microsoft.com/sqlserver) on Linux for Docker Engine.

In comparison to the [official image](https://hub.docker.com/_/microsoft-mssql-server) this image supports custom build arguments e.g. installing Full Text Search or Polybase.

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
| SQL_INSTALL_FULLTEXT        | Install SQL Server Full Text Search (optional). Package `mssql-server-fts`
| SQL_INSTALL_POLYBASE        | Install SQL Server Polybase extension. Package `mssql-server-polybase`
| SQL_INSTALL_POLYBASE_HADOOP | Install SQL Server Polybase Hadoop extension. Package `mssql-server-polybase-hadoop` with the missing package `mssql-zulu-jre-*.deb`

&nbsp;

# Environment variables

| Argument               | Description
| ---------------------- | -------------------------
| ACCEPT_EULA            | Set the ACCEPT_EULA variable to any value to confirm your acceptance of the [End-User Licensing Agreement](https://go.microsoft.com/fwlink/?LinkId=746388). Required setting for the SQL Server image.
| MSSQL_USER             | Create an additional user with sysadmin privileges (optional). This requires `SQL_INSTALL_TOOLS` to be set on build time.
| MSSQL_PASSWORD         | Create an additional user with sysadmin privileges (optional). This requires `SQL_INSTALL_TOOLS` to be set on build time.
| MSSQL_DATABASE         | Creates an database in recovery mode SIMPLE. This requires `SQL_INSTALL_TOOLS` to be set on build time.
| MSSQL_SQLAGENT_ENABLED | If the SQL Server Agent shall be enabled. By default it will be not enabled.

&nbsp;

# Sample build guide

## Minimal build

``` shell
docker build . -t mssql \
    --build-arg ACCEPT_EULA=y
```

## Build with recommended settings

``` shell
docker build . -t mssql \
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

&nbsp;

# Starting the image

You need to provide the `ACCEPT_EULA` environment variable when starting the image:
``` shell
docker run -e 'ACCEPT_EULA=y' mssql
```


You can define a custom user, password and database on run time. This requires that you build the docker image with build arg `SQL_INSTALL_TOOLS`:
``` shell
docker run -e 'ACCEPT_EULA=y' -e 'MSSQL_USER=MySysAdminUser' -e 'MSSQL_PASSWORD=my!Se3u8e$Passw0rd' -e 'MSSQL_DATABASE=MyUserDatabase' mssql
```

&nbsp;

# License

The docker file is released under the [MIT](LICENSE) license.

For Microsoft SQL Server, please have a look at the Microsoft [End-User Licensing Agreement](https://go.microsoft.com/fwlink/?LinkId=746388) and [Microsoft SQL Server](http://www.microsoft.com/sqlserver)
