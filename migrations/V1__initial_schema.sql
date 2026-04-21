-- V1__initial_schema.sql
-- customer_vehicle_db schema — managed by customer-vehicle-service via Prisma.
-- Only Customer and Vehicle domain tables belong here.
-- WorkOrder, Service, PartOrSupply tables have been removed (managed by work-order-service
-- in its own work_order_db database). Cross-service foreign keys have been removed:
-- they are a domain boundary violation in a microservices architecture.
-- CreateTable
CREATE TABLE "public"."Customer" (
    "id" UUID NOT NULL,
    "document" VARCHAR(14) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(13),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    CONSTRAINT "Customer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Vehicle" (
    "id" UUID NOT NULL,
    "customerId" UUID NOT NULL,
    "license_plate" VARCHAR(7) NOT NULL,
    "brand" VARCHAR(100) NOT NULL,
    "model" VARCHAR(100) NOT NULL,
    "year" SMALLINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    CONSTRAINT "Vehicle_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Customer_document_key" ON "public"."Customer"("document");

-- CreateIndex
CREATE INDEX "customer_created_at_idx" ON "public"."Customer"("created_at");

-- CreateIndex
CREATE INDEX "customer_updated_at_idx" ON "public"."Customer"("updated_at");

-- CreateIndex
CREATE UNIQUE INDEX "Vehicle_license_plate_key" ON "public"."Vehicle"("license_plate");

-- CreateIndex
CREATE INDEX "vehicle_created_at_idx" ON "public"."Vehicle"("created_at");

-- CreateIndex
CREATE INDEX "vehicle_updated_at_idx" ON "public"."Vehicle"("updated_at");

-- AddForeignKey (intra-domain: Vehicle → Customer, same bounded context)
ALTER TABLE
    "public"."Vehicle"
ADD
    CONSTRAINT "Vehicle_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "public"."Customer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;