# https://github.com/Microsoft/mssql-docker/blob/master/linux/preview/CentOS/Dockerfile
# https://qiita.com/bezeklik/items/3f88046dd779e86029a2
FROM centos:7

# Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="microsoft/mssql-server-linux" \
      vendor="Microsoft" \
      version="14.0" \
      release="1" \
      summary="MS SQL Server" \
      description="MS SQL Server is ....." \
# Required labels above - recommended below
      url="https://www.microsoft.com/en-us/sql-server/" \
      run='docker run --name ${NAME} \
        -e ACCEPT_EULA=Y -e SA_PASSWORD=yourStrong@Password \
        -p 1433:1433 \
        -d  ${IMAGE}' \
      io.k8s.description="MS SQL Server is ....." \
      io.k8s.display-name="MS SQL Server"

RUN yum --assumeyes install yum-utils && \
    yum-config-manager --add-repo https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo && \
    sed -i 's/packages-microsoft-com-//' /etc/yum.repos.d/mssql-server-2017.repo && \
    ACCEPT_EULA=Y \
    MSSQL_SA_PASSWORD='P@ssw0rd' \
    MSSQL_PID=Developer \
    MSSQL_LCID=1041 \
    yum --assumeyes install mssql-server unixODBC-devel && \
#    /opt/mssql/bin/mssql-conf -n setup && \
    yum --assumeyes install https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm && \
    ACCEPT_EULA=Y \
    yum --assumeyes install mssql-tools && \
    ln -sv /opt/mssql-tools/bin/* /usr/local/bin/ && \
    yum --assumeyes install epel-release && \
    yum --assumeyes install libunwind libicu python-pip  && \
    pip install mssql-cli && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /opt/mssql-tools/bin/
ENV PATH=${PATH}:/opt/mssql/bin:/opt/mssql-tools/bin
RUN mkdir -p /var/opt/mssql/data && \
    chmod -R g=u /var/opt/mssql /etc/passwd

# Containers should not run as root as a good practice
USER 10001

EXPOSE 1433

VOLUME /var/opt/mssql/data

# user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
ENTRYPOINT ["entrypoint.sh"]

CMD sqlservr
