-- CreateEnum
CREATE TYPE "public"."Status" AS ENUM (
    'RECEIVED',
    'IN_DIAGNOSIS',
    'WAITING_APPROVAL',
    'IN_EXECUTION',
    'FINISHED',
    'DELIVERED',
    'CANCELLED'
);

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

-- CreateTable
CREATE TABLE "public"."PartOrSupply" (
    "id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "price" DOUBLE PRECISION NOT NULL,
    "in_stock" SMALLINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    CONSTRAINT "PartOrSupply_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Service" (
    "id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "price" DOUBLE PRECISION NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    CONSTRAINT "Service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."WorkOrder" (
    "id" UUID NOT NULL,
    "customerId" UUID NOT NULL,
    "vehicleId" UUID NOT NULL,
    "status" "public"."Status" NOT NULL,
    "budget" DOUBLE PRECISION NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    CONSTRAINT "WorkOrder_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."WorkOrderPartOrSupply" (
    "id" UUID NOT NULL,
    "workOrderId" UUID NOT NULL,
    "partOrSupplyId" UUID NOT NULL,
    "quantity" SMALLINT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "WorkOrderPartOrSupply_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."WorkOrderService" (
    "id" UUID NOT NULL,
    "workOrderId" UUID NOT NULL,
    "serviceId" UUID NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "WorkOrderService_pkey" PRIMARY KEY ("id")
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

-- CreateIndex
CREATE UNIQUE INDEX "PartOrSupply_name_key" ON "public"."PartOrSupply"("name");

-- CreateIndex
CREATE INDEX "part_or_supply_created_at_idx" ON "public"."PartOrSupply"("created_at");

-- CreateIndex
CREATE INDEX "part_or_supply_updated_at_idx" ON "public"."PartOrSupply"("updated_at");

-- CreateIndex
CREATE UNIQUE INDEX "Service_name_key" ON "public"."Service"("name");

-- CreateIndex
CREATE INDEX "service_created_at_idx" ON "public"."Service"("created_at");

-- CreateIndex
CREATE INDEX "service_updated_at_idx" ON "public"."Service"("updated_at");

-- CreateIndex
CREATE INDEX "work_order_status_idx" ON "public"."WorkOrder"("status");

-- CreateIndex
CREATE INDEX "work_order_created_at_idx" ON "public"."WorkOrder"("created_at");

-- CreateIndex
CREATE INDEX "work_order_updated_at_idx" ON "public"."WorkOrder"("updated_at");

-- CreateIndex
CREATE INDEX "work_order_part_or_supply_created_at_idx" ON "public"."WorkOrderPartOrSupply"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "work_order_part_or_supply_unique" ON "public"."WorkOrderPartOrSupply"("workOrderId", "partOrSupplyId");

-- CreateIndex
CREATE INDEX "work_order_service_price_idx" ON "public"."WorkOrderService"("price");

-- CreateIndex
CREATE INDEX "work_order_service_created_at_idx" ON "public"."WorkOrderService"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "work_order_service_unique" ON "public"."WorkOrderService"("workOrderId", "serviceId");

-- AddForeignKey
ALTER TABLE
    "public"."Vehicle"
ADD
    CONSTRAINT "Vehicle_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "public"."Customer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE
    "public"."WorkOrder"
ADD
    CONSTRAINT "WorkOrder_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "public"."Customer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE
    "public"."WorkOrder"
ADD
    CONSTRAINT "WorkOrder_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "public"."Vehicle"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE
    "public"."WorkOrderPartOrSupply"
ADD
    CONSTRAINT "WorkOrderPartOrSupply_workOrderId_fkey" FOREIGN KEY ("workOrderId") REFERENCES "public"."WorkOrder"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE
    "public"."WorkOrderPartOrSupply"
ADD
    CONSTRAINT "WorkOrderPartOrSupply_partOrSupplyId_fkey" FOREIGN KEY ("partOrSupplyId") REFERENCES "public"."PartOrSupply"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE
    "public"."WorkOrderService"
ADD
    CONSTRAINT "WorkOrderService_workOrderId_fkey" FOREIGN KEY ("workOrderId") REFERENCES "public"."WorkOrder"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE
    "public"."WorkOrderService"
ADD
    CONSTRAINT "WorkOrderService_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "public"."Service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;