# loyalty-service
A fullstack loyalty service using Ruby and ReactJS as backend and frontend

# How I create the service
This service have two microservice between backend and frontend, the plan was:
- Create 2 microservice to handle the backend and frontend.
- Frontend side will be using ReactJS and Vite for scaffolding.
- Backend side will be using Ruby with Sinatra Framework and using JSON API as connection between this service to frontend service.
- Create docker for each of the service and create docker-compose to run all the service simultaneously but only open the port to frontend only so that the connection between frontend and backend is only a connection between docker.
- Create a cronjob and then setting up a job to create loyalty_tier data for uniq customer_id inside the completed_order table and run the job only when it's the beginning of the year.
- All of the total is in cents but then from the frontend side it will converted to dollar by divide it by 100.

# Implementation
- I already run the scaffolding for ReactJS using Vite.
- Create table :
  - completed_order: This is created when the endpoint `POST /order_completed` is requested.
  - loyalty_tier: This is to save the tier for each customer_id and this table should be created only by the cron job.
- Create helper folder to handle some checking like:
  - getting a tier based on the amount.
  - getting next tier based on the current tier. (e.g. if current tier is `silver` then it will return `gold`)
  - Calculate total order in cents in a year based on the customer_id and what year.
- Inside the model of loyalty tier there is some logic to handling:
  - Amount needed for next tier based on the current tier.
  - Getting next year tier for specific customer_id and it will return nil if the next year tier will be the same or higher than current tier.
  - Getting amount needed next year to get the same tier as current tier and it will return zero if next year tier will be the same or higher than current tier.
  - Creating loyalty tier based on the customer_id.
- Already implemented unit test for Helper and Model.

# List of feature done
- Creating an endpoint to save completed order.
- Creating an endpoint to return customer information about tier based on customer_id.
- Creating an endpoint to return list of completed order based on customer_id.
- Already create a method to create loyalty_tier.

# List of feature not done
- All of the frontend app feature.
- The cronjob to create loyalty_tier for every customer_id at the beginning of year.

# How to test
- cd to `/api`
- run `bundle install` (please make sure you already install bundler)
- run `bundle exec rake db:create`
- run `bundle exec rake db:migrate`
- run `bundle exec puma config.ru`
- run `bundle exec rspec` - This is just to run the unit test
