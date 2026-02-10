# 📊 Data Pipeline Archetype

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [📊 Data Pipeline](#)

---

## Description

Шаблон для создания ETL/ELT пайплайнов, данныхх инженерных решений и ML пайплайнов.

---

## 🎯 Характеристики

### Tech Stack

| Компонент | Технология |
|-----------|------------|
| **Orchestration** | Apache Airflow / Prefect |
| **Transformation** | dbt / SQL / Python |
| **Warehouse** | Snowflake / BigQuery / PostgreSQL |
| **Data Lake** | AWS S3 / GCS / Azure Blob |
| **Streaming** | Apache Kafka / AWS Kinesis |
| **Processing** | Python Pandas / Polars / Spark |
| **Monitoring** | Airflow Monitoring / Grafana |

### Features Out-of-the-Box

✅ **Orchestrator Ready** — Airflow DAGs с best practices
✅ **dbt Integration** — трансформация данных в SQL
✅ **Data Quality** — проверки качества данных
✅ **Lineage Tracking** — отслеживание происхождения данных
✅ **Monitoring** — alerting на failure
✅ **Testing** — unit тесты для пайплайнов
✅ **CI/CD** — деплой DAG через GitHub Actions
✅ **Documentation** — auto-generated docs

---

## 🚀 Quick Start

### 1. Создание проекта

**Через CodeFoundry (рекомендуется):**
```bash
cd CodeFoundry
make new ARCHETYPE=data-pipeline NAME=my-pipeline
cd my-pipeline
```

**Вручную:**
```bash
cp -r /path/to/CodeFoundry/templates/archetypes/data-pipeline ~/projects/my-pipeline
cd ~/projects/my-pipeline
git init
```

### 2. Конфигурация

```bash
cp .env.example .env
nano .env
```

### 3. Запуск Airflow

```bash
# Docker Compose
make dev

# Доступ к Airflow Web UI
open http://localhost:8080
```

---

## 📂 Структура Проекта

```
data-pipeline/
├── 📋 docs/
│   ├── ARCHITECTURE.md
│   ├── DAG_GUIDE.md
│   └── DBT_GUIDE.md
│
├── 🐳 docker/
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── 📊 dags/
│   ├── __init__.py
│   ├── raw_ingestion/
│   │   ├── ingest_postgres.py
│   │   └── ingest_api.py
│   ├── transformations/
│   │   ├── dbt_run.py
│   │   └── sql_transformations.py
│   └── monitoring/
│       ├── data_quality.py
│       └── lineage_update.py
│
├── 📦 dbt/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   ├── seeds/
│   ├── macros/
│   └── dbt_project.yml
│
├── 📝 sql/
│   ├── stored_procedures/
│   └── migrations/
│
├── 🧪 tests/
│   ├── unit/
│   ├── integration/
│   └── data_quality/
│
├── 🤖 openclaw/
│   └── workspace/
│       ├── AGENTS.md
│       └── skills/
│
├── 📝 src/
│   ├── operators/
│   ├── hooks/
│   ├── sensors/
│   └── utils/
│
└── 🔧 scripts/
    ├── setup-airflow.sh
    └── deploy-dags.sh
```

---

## 🤖 OpenClaw Integration

### Multi-Agent Configuration

```
Main Agent (Координатор)
    ├── Dev Agent (Код DAG)
    ├── DataEngineer (ETL задачи)
    ├── MLEngine (ML модели)
    └── Review Agent (Ревью)
```

---

## 📊 DAG Examples

### Basic ETL DAG

```python
# dags/etl/etl_pipeline.py
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
from app.operators.extract import ExtractOperator
from app.operators.load import LoadOperator

with DAG(
    'etl_pipeline',
    default_args={
        'owner': 'data-engineering',
        'start_date': datetime(2024, 1, 1),
        'retries': 3,
        'retry_delay': timedelta(minutes=5),
    },
    schedule_interval='0 2 * * *',  # Daily at 2 AM
    catchup=False,
    tags=['etl', 'production'],
) as dag:

    extract = ExtractOperator(
        task_id='extract_from_source',
        source='postgres',
        table='users'
    )

    transform = PythonOperator(
        task_id='transform_data',
        python_callable=transform_users
    )

    load = LoadOperator(
        task_id='load_to_warehouse',
        destination='snowflake',
        table='dim_users'
    )

    extract >> transform >> load
```

### dbt DAG

```python
# dags/transformations/dbt_run.py
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    'dbt_daily_run',
    default_args={
        'owner': 'data-engineering',
        'start_date': datetime(2024, 1, 1),
    },
    schedule_interval='0 3 * * *',
    catchup=False,
) as dag:

    dbt_run = BashOperator(
        task_id='dbt_run_models',
        bash_command='cd /opt/dbt && dbt run --profiles-dir profiles',
    )

    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /opt/dbt && dbt test --profiles-dir profiles',
    )

    dbt_run >> dbt_test
```

---

## 📦 dbt Models

### dbt Project Structure

```sql
-- models/staging/stg_users.sql
with source as (
    select * from {{ source('raw', 'users') }}
),

renamed as (
    select
        id as user_id,
        email as user_email,
        created_at
    from source
)

select * from renamed
```

```sql
-- models/marts/dim_user_metrics.sql
with user_orders as (
    select
        user_id,
        count(*) as total_orders,
        sum(amount) as lifetime_value
    from {{ ref('fct_orders') }}
    group by user_id
),

user_attributes as (
    select * from {{ ref('stg_users') }}
)

select
    u.*,
    coalesce(o.total_orders, 0) as total_orders,
    coalesce(o.lifetime_value, 0) as lifetime_value
from user_attributes u
left join user_orders o using (user_id)
```

---

## 🧪 Data Quality Checks

```python
# tests/data_quality/test_data_quality.py
import pytest
from app.utils.data_quality import check_nulls, check_duplicates

def test_users_no_nulls():
    """Check that user_id has no nulls"""
    result = check_nulls('dim_users', 'user_id')
    assert result.null_count == 0

def test_users_unique():
    """Check that user_id is unique"""
    result = check_duplicates('dim_users', 'user_id')
    assert result.duplicate_count == 0

def test_data_freshness():
    """Check that data is fresh"""
    result = check_freshness('dim_users', max_age_hours=24)
    assert result.is_fresh
```

---

## 🔧 Makefile Commands

```bash
make help           # Show all commands
make init           # Initialize project
make dev            # Start Airflow
make dbt-deps       # Install dbt dependencies
make dbt-run        # Run dbt models
make dbt-test       # Test dbt models
make dbt-docs       # Generate dbt docs
make test           # Run tests
make deploy-airflow # Deploy DAGs
```

---

## 📚 Additional Resources

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)
- [📋 Все Архетипы](../README.md)
- [🔄 GitOps 2.0](../README.md)

### OpenClaw Integration
- [🦞 OpenClaw README](../../../openclaw/README.md)
- [🤖 Agents](../../../openclaw/workspace/AGENTS.md)
- [🎨 Skills Index](../../../openclaw/workspace/SKILLS-INDEX.md)

### Data Engineering Documentation
- [📖 Airflow Guide](https://airflow.apache.org/docs/)
- [📦 dbt Docs](https://docs.getdbt.com/)
- [📖 PostgreSQL Docs](https://www.postgresql.org/docs/)

### Pipeline Resources
- [📖 Data Engineering Guide](https://www.dataengineeringwiki.com/)
- [📊 Best Practices](https://www.tressotechnical.com/)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.2.0 | 2025-01-31 | GitOps 2.0 добавлен, исправлены сломанные ссылки |
| 1.1.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs |
| 1.0.0 | 2025-11-05 | Первая версия archetype |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [📊 Data Pipeline](#)
