FROM python:3.7.4-stretch

RUN apt-get update && \
    apt-get install apt-transport-https && \
    apt-get -y install lsb-release && \
    apt-get -y install vim && \
    #apt-get -y install unixodbc unixodbc-dev && \
    apt-get -y install freetds-bin freetds-dev && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    pip install --no-cache-dir --upgrade pip ansible packaging termcolor && \
    pip install --no-cache-dir --upgrade ansible[azure] && \
    pip install --no-cache-dir ruamel.yaml && \
    pip install --no-cache-dir azure.keyvault && \
    pip install --no-cache-dir azure.servicebus && \ 
    pip install --no-cache-dir azure.mgmt.servicebus && \
    pip install --no-cache-dir pymssql && \  
    pip install --no-cache-dir boto && \
    pip install --no-cache-dir boto3 && \    
    pip install --no-cache-dir jsonpointer && \
    pip install --no-cache-dir influxdb && \
    apt-get update && apt-get install azure-cli && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    touch /etc/apt/sources.list.d/kubernetes.list && \
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh && \
    chmod 700 get_helm.sh

RUN ./get_helm.sh --version v2.8.1 && \
    export LC_ALL=C && \
    sed -i '/\[global\]/a \ \ \ \ \ \ \ \ tds version = 7.0' /etc/freetds/freetds.conf && \
    sed -i '/\[global\]/a \ \ \ \ \ \ \ \ locale = en_us.UTF-8' /etc/freetds/freetds.conf && \
    sed -i '/\[global\]/a \ \ \ \ \ \ \ \ client charset = UTF-8' /etc/freetds/freetds.conf && \
    apt-get install uuid-runtime && \
    apt-get -y install default-jdk && \
    wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.6.2/liquibase-3.6.2-bin.tar.gz -O liquibase-3.6.2-bin.tar.gz && \
    mkdir /opt/liquibase && \
    tar zxvf liquibase-3.6.2-bin.tar.gz -C /opt/liquibase && \
    rm liquibase-3.6.2-bin.tar.gz  && \
    chmod +x /opt/liquibase/liquibase && \
    wget https://oss.sonatype.org/content/repositories/releases/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar -O /opt/liquibase/lib/slf4j-api-1.7.25.jar  && \
    wget https://oss.sonatype.org/content/repositories/releases/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar -O /opt/liquibase/lib/slf4j-simple-1.7.25.jar && \
    wget https://oss.sonatype.org/content/repositories/releases/com/microsoft/sqlserver/mssql-jdbc/7.0.0.jre8/mssql-jdbc-7.0.0.jre8.jar -O /opt/liquibase/lib/mssql-jdbc-7.0.0.jre8.jar && \
    ln -s /opt/liquibase/liquibase /bin/liquibase
    
CMD bash
