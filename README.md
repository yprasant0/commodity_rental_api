# Commodity Rental Solution

The Commodity Rental Solution is a Ruby on Rails API that facilitates the renting and lending of various commodities. This README provides instructions on how to set up and run the application

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- Docker
- Docker Compose
- Git

## Getting Started

Follow these steps to get the Commodity Rental Solution up and running on your local machine:

### 1. Clone the repository:
```bash
git clone https://github.com/yprasant0/commodity_rental_api.git
cd commodity-rental-api
```

### 1. Create a .env file in the project root and add the following environment variables:

```bash
DATABASE_URL=postgres://postgres:password@db:5432/commodity_rental_development
RAILS_ENV=development
RAILS_MASTER_KEY=your_rails_master_key_here
```
### 3. Build the Docker images and run following command:
```bash
docker-compose build
docker-compose up
docker-compose run web rails db:create db:migrate
```
#### The application should now be running and accessible at http://localhost:3000.

### 5. to run the rails console
```bash
docker-compose run web rails console
```
## Post Collection

#### Contains all the API collection

```bash
https://app.getpostman.com/run-collection/8983445-baf719c1-b068-4113-8fd4-fec3bbd41f52?action=collection%2Ffork&source=rip_markdown&collection-url=entityId%3D8983445-baf719c1-b068-4113-8fd4-fec3bbd41f52%26entityType%3Dcollection%26workspaceId%3D0e57f0e8-bfe8-4c89-bf61-8ac02fddb2d0
```
## Database Schema

```bash
erDiagram
    USER ||--o{ COMMODITY : lists
    USER ||--o{ BID : places
    USER ||--o{ RENTAL : rents
    COMMODITY ||--o{ BID : receives
    COMMODITY ||--o{ RENTAL : has
    BID ||--o| RENTAL : results_in

    USER {
        int id
        string email
        string encrypted_password
        string role
        string first_name
        string last_name
    }
    COMMODITY {
        int id
        int lender_id
        string name
        string description
        string category
        decimal minimum_monthly_charge
        string status
        string bid_strategy
    }
    BID {
        int id
        int commodity_id
        int renter_id
        decimal monthly_price
        int lease_period
        string status
    }
    RENTAL {
        int id
        int commodity_id
        int renter_id
        date start_date
        date end_date
        decimal monthly_price
        string status
    }
```


## Key Design Patterns and Principles
### 1. Service Object Pattern

Encapsulates business logic
Keeps controllers thin
Improves testability and maintainability

### 2. Command Pattern

Implemented via ApplicationService
Standardizes service invocation: SomeService.call(args)

### 3. Repository Pattern (Partial Implementation)

ActiveRecord models act as repositories
Custom query methods encapsulate data access logic

### 4. State Machine Pattern

Used in Commodity model for status management
Implemented using the AASM gem

### 5. Observer Pattern (Partial Implementation)

Background job system acts as a simple observer pattern

CloseBidWindowJob observes commodity creation events

