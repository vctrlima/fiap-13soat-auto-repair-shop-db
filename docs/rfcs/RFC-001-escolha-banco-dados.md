# RFC-003: Escolha do Banco de Dados e Estratégia de Dados

## Metadados

| Campo         | Valor                   |
| ------------- | ----------------------- |
| **Autor**     | Equipe Auto Repair Shop |
| **Data**      | 2026-01-12              |
| **Status**    | Aprovado                |
| **Revisores** | Equipe de Arquitetura   |

## Resumo

Esta RFC documenta a decisão sobre o banco de dados para o sistema Auto Repair Shop, incluindo justificativa técnica, modelo relacional, estratégia de migrations e configuração do serviço gerenciado.

## Motivação

O sistema gerencia dados de clientes, veículos e ordens de serviço com relacionamentos complexos e necessidade de consistência transacional. A escolha do banco impacta performance, custo operacional e complexidade de manutenção.

## Proposta Detalhada

### Análise de Requisitos de Dados

| Requisito                                             | Implicação                            |
| ----------------------------------------------------- | ------------------------------------- |
| Relacionamentos N:N (OS ↔ Serviço, OS ↔ Peça)         | Banco relacional com JOINs            |
| Transações multi-tabela (criar OS + serviços + peças) | ACID compliance                       |
| Queries agregadas (relatórios, métricas por status)   | SQL avançado (CTEs, window functions) |
| Auditoria (timestamps)                                | Campos de data em todas as tabelas    |
| Volume esperado: ~1000 OS/mês                         | Não requer sharding/distribuição      |

### Decisão: PostgreSQL 16 em AWS RDS

Escolhemos PostgreSQL 16 pelos motivos detalhados no [ADR-001: Escolha do PostgreSQL](../adrs/ADR-001-escolha-postgresql.md).

### Modelo Relacional

```mermaid
erDiagram
    Customer ||--o{ Vehicle : owns
    Customer ||--o{ WorkOrder : requests
    Vehicle ||--o{ WorkOrder : "serviced in"
    WorkOrder ||--o{ WorkOrderService : contains
    WorkOrder ||--o{ WorkOrderPartOrSupply : uses
    Service ||--o{ WorkOrderService : "provided in"
    PartOrSupply ||--o{ WorkOrderPartOrSupply : "used in"

    Customer {
        uuid id PK
        string name
        string email
        string document "CPF/CNPJ"
        string phone
        datetime createdAt
    }

    Vehicle {
        uuid id PK
        uuid customerId FK
        string licensePlate "ABC1234 / ABC1D23"
        string brand
        string model
        int year
        string color
        datetime createdAt
    }

    WorkOrder {
        uuid id PK
        uuid customerId FK
        uuid vehicleId FK
        enum status "OPEN|DIAGNOSIS|IN_PROGRESS|DONE|CLOSED"
        string description
        datetime estimatedCompletionDate
        datetime createdAt
    }

    Service {
        uuid id PK
        string name
        string description
        float price
        datetime createdAt
    }

    PartOrSupply {
        uuid id PK
        string name
        string description
        float unitPrice
        int stockQuantity
        datetime createdAt
    }

    WorkOrderService {
        uuid id PK
        uuid workOrderId FK
        uuid serviceId FK
        float price
    }

    WorkOrderPartOrSupply {
        uuid id PK
        uuid workOrderId FK
        uuid partOrSupplyId FK
        int quantity
        float price
    }

    User {
        uuid id PK
        string name
        string email
        string password "bcrypt hash"
        enum role "ADMIN|MECHANIC"
        datetime createdAt
    }
```

### Estratégia de Migrations

| Aspecto          | Decisão                                                 |
| ---------------- | ------------------------------------------------------- |
| **Ferramenta**   | Prisma Migrate (aplicação) + SQL nativo (bootstrap)     |
| **Nomenclatura** | `V{N}__{description}.sql` (Flyway-compatible)           |
| **Execução**     | Aplicada no Docker entrypoint (`prisma migrate deploy`) |
| **Rollback**     | Manual (scripts SQL reversos)                           |
| **Seed**         | Seed de produção cria admin padrão na primeira execução |

### Configuração RDS

| Setting              | Staging     | Production  |
| -------------------- | ----------- | ----------- |
| Instância            | db.t3.micro | db.t3.small |
| Storage              | 20GB gp3    | 50GB gp3    |
| Backup retention     | 7 dias      | 14 dias     |
| Multi-AZ             | Não         | Recomendado |
| Encryption           | Sim (KMS)   | Sim (KMS)   |
| Enhanced Monitoring  | 60s         | 60s         |
| Performance Insights | Sim         | Sim         |
| Deletion Protection  | Não         | Sim         |

### Segurança

- **Rede**: RDS em subnets privadas, acessível apenas por Security Group que permite ingress da VPC
- **Credenciais**: Armazenadas no AWS Secrets Manager, sincronizadas para K8s via ExternalSecrets
- **Encryption at rest**: AES-256 via KMS
- **Encryption in transit**: SSL/TLS obrigatório
- **Logs**: PostgreSQL logs exportados para CloudWatch

## Impacto

- **Consistência**: ACID garante integridade transacional
- **Observabilidade**: Performance Insights e Enhanced Monitoring sem overhead
- **Segurança**: Dados isolados em VPC, criptografados em repouso e trânsito
- **Custo**: RDS db.t3.micro (staging) ~$15/mês; db.t3.small (prod) ~$30/mês

## Decisão

Aprovado. PostgreSQL 16 em RDS implementado conforme especificado, com infraestrutura provisionada via Terraform no repositório `fiap-13soat-auto-repair-shop-db`.
