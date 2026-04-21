# Production environment
environment          = "production"
region               = "us-east-1"
project_name         = "auto-repair-shop"
db_instance_class    = "db.t3.micro"
db_name              = "customer_vehicle_db"
db_allocated_storage = 20
db_max_allocated_storage = 100
db_backup_retention_period = 7
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

tags = {
  Project     = "auto-repair-shop"
  ManagedBy   = "terraform"
  Environment = "production"
}
