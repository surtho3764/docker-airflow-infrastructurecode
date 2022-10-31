<!--
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
-->


# Apache Airflow Docker
### Apache Airflow
[Reference website](https://github.com/puckel/docker-airflow)

Apache Airflow (or simply Airflow) is a platform to programmatically author, schedule, and monitor workflows.

When workflows are defined as code, they become more maintainable,
versionable, testable, and collaborative.

Use Airflow to author workflows as directed acyclic graphs (DAGs) of tasks. The Airflow scheduler executes your tasks on an array of workers while following the specified dependencies. Rich command line utilities make performing complex surgeries on DAGs a snap. The rich user interface makes it easy to visualize pipelines running in production, monitor progress, and troubleshoot issues when needed.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of contents**

- [Installation](#Installation)
- [Usage](#Usage)
- [Custom Airflow configure](#Custom-Airflow-configures)
- [UI Links](#UI-Links)
- [Running other airflow commands](#Running-other-airflow-commands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Installation

Build ubuntu/docker-airflow:1.10.9 image

```bash
git clone git@github.com:surtho3764/docker-airflow-infrastructurecode.git
cp airflow-infrastructurecode -r target_dir
cd ./target_dir/airflow-infrastructurecode
docker build -t ubuntu/docker-airflow:1.10.9 .
```

## Usage
docker-airflow runs Airflow with 
LocalExecutor :dev
```bash
docker-compose -f docker-compose-LocalExecutor.yml up -d
```

For CeleryExecutor :prod
```bash
docker-compose -f docker-compose-CeleryExecutor.yml up -d
```

No Load Dags example
If you will to have DAGs example loaded (default=False)you've to set the following environment variable :
Edit
 ```bash
AIRFLOW__CORE__LOAD_EXAMPLES=True
 ```

## Custom-Airflow-configures

File :airflow.cfg

Airflow allows for custom user-created plugins which are typically found in `${AIRFLOW_HOME}/plugins` folder. Documentation on plugins can be found [here](https://airflow.apache.org/plugins.html)

In order to incorporate plugins into your docker container
- Create the plugins folders `plugins/` with your custom plugins.
- Mount the folder as a volume by doing either of the following:
    - Include the folder as a volume in command-line `-v $(pwd)/plugins/:/usr/local/airflow/plugins`
    - Use docker-compose-LocalExecutor.yml or docker-compose-CeleryExecutor.yml which contains support for adding the plugins folder as a volume


## UI Links

- Airflow: [localhost:8080](http://localhost:8080/)
- Flower: [localhost:5555](http://localhost:5555/)


## Running other airflow commands

 ```bash
docker exec -ti container_id /bin/bsah
 ```
