# ADR-005: Escolha do PostgreSQL como Banco de Dados Relacional

## Status

Aceito

## Contexto

O sistema Auto Repair Shop precisa de um banco de dados para gerenciar dados de clientes, veículos, ordens de serviço e execução. Cada microserviço mantém seu próprio banco lógico em uma única instância RDS. Os dados possuem relacionamentos internos a cada domínio e transacões que exigem consistência (ACID).

Bancos de dados avaliados:

- **PostgreSQL** (Open-source, relacional)
- **MySQL** (Open-source, relacional)
- **SQL Server** (Microsoft, relacional)
- **MongoDB** (Document store, NoSQL)
- **DynamoDB** (Key-value, NoSQL gerenciado AWS)

## Decisão

Adotamos **PostgreSQL 16** em RDS (Relational Database Service) gerenciado da AWS.

## Justificativa

### Por que Relacional (e não NoSQL)?

1. **Modelo de dados relacional**: O domínio de Customer & Vehicle possui relacionamento forte (Customer → Vehicle) que se mapeia naturalmente em tabelas relacionais. Work Order e Execution também possuem entidades compostas (WorkOrder → WorkOrderService).
2. **Integridade referencial**: Foreign keys dentro de cada domínio garantem consistência nas operações de CRUD.
3. **Transações ACID**: Ordens de serviço envolvem múltiplas operações que devem ser atômicas.
4. **Queries complexas**: Relatórios e métricas são naturalmente expressas em SQL.

### Por que PostgreSQL (e não MySQL/SQL Server)?

1. **Performance superior em queries complexas**: PostgreSQL possui melhor otimizador de queries, suporte a CTEs recursivas, window functions e JSON nativo.
2. **Tipos nativos avançados**: `UUID`, `JSONB`, `ENUM`, `TIMESTAMP WITH TIMEZONE` são nativos.
3. **Extensibilidade**: Suporta extensions como `pg_trgm` (busca por similaridade), `uuid-ossp` e `pgcrypto`.
4. **Licença BSD**: Totalmente open-source sem restrições de uso comercial.
5. **Suporte RDS maduro**: AWS RDS para PostgreSQL oferece backups automáticos, réplicas de leitura, Performance Insights e Enhanced Monitoring.
6. **Compatibilidade com Prisma**: O ORM Prisma possui suporte de primeira classe para PostgreSQL, incluindo migrations e introspecção de schema.

### Por que RDS (gerenciado)?

1. **Operações simplificadas**: Backups, patching, failover, encryption at rest são gerenciados pela AWS.
2. **Performance Insights**: Monitoramento de queries sem overhead.
3. **Enhanced Monitoring**: Métricas detalhadas de OS (CPU, memória, I/O) a cada 60 segundos.
4. **Encryption at rest e in transit**: Dados criptografados automaticamente com KMS.
5. **Security Groups**: Isolamento de rede — apenas subnets privadas podem acessar o banco.

## Modelo de Dados (ER)

```
Customer 1──N Vehicle
Customer 1──N WorkOrder
Vehicle  1──N WorkOrder
WorkOrder 1──N WorkOrderService
WorkOrder 1──N WorkOrderPartOrSupply
Service  1──N WorkOrderService
PartOrSupply 1──N WorkOrderPartOrSupply
```

### Entidades Principais

| Entidade     | Descrição              | Campos-chave                                                                              |
| ------------ | ---------------------- | ----------------------------------------------------------------------------------------- |
| Customer     | Cliente da oficina     | id, name, email, document (CPF/CNPJ), phone                                               |
| Vehicle      | Veículo do cliente     | id, licensePlate, brand, model, year, color                                               |
| WorkOrder    | Ordem de serviço       | id, status (OPEN→DIAGNOSIS→IN_PROGRESS→DONE→CLOSED), description, estimatedCompletionDate |
| Service      | Serviço oferecido      | id, name, description, price                                                              |
| PartOrSupply | Peça ou suprimento     | id, name, description, unitPrice, stockQuantity                                           |
| User         | Usuário administrativo | id, name, email, password (bcrypt), role (ADMIN/MECHANIC)                                 |

### Enums Utilizados

- **WorkOrderStatus**: `OPEN`, `DIAGNOSIS`, `IN_PROGRESS`, `DONE`, `CLOSED`
- **UserRole**: `ADMIN`, `MECHANIC`

## Ajustes no Modelo Relacional

1. **Tabelas intermediárias** (`WorkOrderService`, `WorkOrderPartOrSupply`): Relações N:N com campos adicionais (`price`, `quantity`) para histórico de preços.
2. **Status como ENUM**: Uso de PostgreSQL ENUM para garantir valores válidos e legíveis.
3. **UUID como primary key**: Evita enumeração e melhora segurança em APIs REST.
4. **Timestamps**: `created_at` em todas as tabelas para auditoria.
5. **Indexes**: Otimizados para queries frequentes (FK lookups, filtro por status).

## Ajustes no Modelo

1. **UUID como primary key**: Evita enumeração e melhora segurança em APIs REST.
2. **Timestamps**: `created_at` em todas as tabelas para auditoria.
3. **Indexes**: Otimizados para queries frequentes (FK lookups, filtro por status).
4. **Sem FKs entre bancos**: Cada microserviço é dono do seu banco; referências cross-service são IDs opacos.

## Consequências

- **Positivas**: Integridade de dados intra-domínio garantida, queries complexas eficientes, operações gerenciadas, segurança e criptografia nativas. Isolamento entre serviços por banco lógico.
- **Negativas**: Custo de RDS (mitigado por instâncias rightsized: `db.t3.small` em staging, `db.t3.medium` em produção). Escalabilidade vertical (mitigado por read replicas se necessário).

## Alternativas Consideradas

| Banco      | Prós                                | Contras                                            |
| ---------- | ----------------------------------- | -------------------------------------------------- |
| MySQL      | Popular, simples                    | Otimizador inferior, menos tipos nativos           |
| SQL Server | Enterprise, BI integrado            | Custo de licença, vendor lock-in Microsoft         |
| MongoDB    | Schema flexível, horizontal scaling | Sem integridade referencial, eventual consistency  |
| DynamoDB   | Serverless, auto-scaling            | Modelo key-value inadequado para queries complexas |
