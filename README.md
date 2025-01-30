## Requirements
To make this app work make sure you have this installed on your computer:
- Python(use `pyenv` to install and manage compatible versions [3.12/3.11])
- PostgreSQL
- Node.js and npm
- Git

GroceryMate


Overview

GroceryMate is a comprehensive e-commerce platform offering the following features:

    User Authentication: Register and login functionality.
    Protected Routes: All the routes that need to be authenticated will redirect to /auth
    Product Search: Search for products, sort them by price, and filter by categories.
    Favorites: Add products to your favorites list.
    Shopping Basket: Add products to your basket and manage them.
    Check-out Process: Complete the checkout process with billing and shipping information, choose payment methods, and calculate the total price.

Features

    Register, Login, and Logout: Secure user authentication system.
    Product Search and Sorting: Search for products, and sort them by price or name in both ASC and DESC.
    Product Category and Price Range: Get the product by categories or range of price
    Favorites: Manage your favorite products.
    Shopping Basket: Add products to your basket, view, and modify the contents.
    Check-out Process:
        Billing and Shipping Information
        Payment Method Selection
        Total Price Calculation

Screenshots and videos


![imagen](https://github.com/user-attachments/assets/ea039195-67a2-4bf2-9613-2ee1e666231a)
![imagen](https://github.com/user-attachments/assets/a87e5c50-5a9e-45b8-ad16-2dbff41acd00)
![imagen](https://github.com/user-attachments/assets/589aae62-67ef-4496-bd3b-772cd32ca386)
![imagen](https://github.com/user-attachments/assets/2772b85e-81f7-446a-9296-4fdc2b652cb7)

https://github.com/user-attachments/assets/d1c5c8e4-5b16-486a-b709-4cf6e6cce6bc




Installation

Follow these steps to set up the application locally.
Create .env files in the backend and frontend, and follow the .env.examples to know what is required

## Clone repository

Clone the repository:

    git clone --branch version1 https://github.com/AlejandroRomanIbanez/AWS_grocery.git
    

## Install pyenv and python (if you haven't yet)


### On macOS/Linux:

Follow the instructions [here](https://github.com/pyenv/pyenv-installer) to install pyenv

### On Windows:

Use pyenv-win, you can find it [here](https://github.com/pyenv-win/pyenv-win), follow the instructions to install it

### Install Python with `pyenv` (if you don't have it on your machine yet)

Install Python 3.12.x (or 3.11.x): 

    pyenv install 3.12.1

Check Python version now using:

    python3 --version

You should see the version you installed (e.g., `3.12.1`).

## Continue with the project installation
Open the project in your preferred IDE (e.g., PyCharm).

Open the IDE terminal.

Navigate to the backend folder:

    cd backend

Create a virtual environment: 

    python3 -m venv venv

Activate the virtual environment: 
 - On macOS/Linux: 


    source venv/bin/activate  
- On Windows use


    venv\Scripts\activate

Install Requirements:

    pip install -r requirements.txt

Create an `.env` file for the backend:

- On macOS:

  - Use nano to create the `.env` file:

        touch .env

- On Windows:

  - Use ni to create the `.env` file

        ni .env -Force
       
  
Generate the JWT Secret Key 
- To generate a secure `JWT_SECRET_KEY`, run the following command:

      python -c "import secrets; print(secrets.token_hex(32))"

Example:
  `094bb15924a8a63d82f612b978e8bc758d5c3f0330a41beefb36f45b587411d4`
- This key will be used to secure user sessions
- Copy the generated key from your terminal

Edit the .env file

- On macOS:

      nano .env

  Paste your copied JWT Secret Key into the file like this
`JWT_SECRET_KEY=094bb15924a8a63d82f612b978e8bc758d5c3f0330a41beefb36f45b587411d4`

  Also paste enviroment variable for flask:

      FLASK_ENV=development
  Exit and save.


- On Windows:
  
      notepad .env

  Paste your copied JWT Secret Key into the file like this
`JWT_SECRET_KEY=094bb15924a8a63d82f612b978e8bc758d5c3f0330a41beefb36f45b587411d4`

  Also paste enviroment variable for flask:

      FLASK_ENV=development
  Exit and save.


## Frontend

Navigate to the Frontend Directory:

    cd ../frontend

Create the `.env` File for the Frontend. Use same commands for creating and editing .env files as [above]((#create-an-env-file-for-the-backend))

- Set a port for your backend server inside the .env file:
  
      REACT_APP_BACKEND_SERVER=http://localhost:5000

Install Dependencies and generate the build:
    
    npm install
    npm run build


Start the Application:
    
        cd ../backend
        python run.py

Navigate and get familiar with the app

Usage

    Register or Login:
        Open the application in your browser ---> http://localhost:5000
        Register a new account or log in with your existing credentials.

    Upload avatars:
        Upload an image and use it as the avatar of the user

    Search for Products:
        Use the search bar to find products.
        Sort products by price or filter by categories in store.

    Products:
        Add, edit, or delete reviews of products you buyed

    Add to Favorites and Basket:
        Add products to your favorites list for quick access.
        Add products to your basket to proceed with the purchase.

    Checkout:
        Go to your basket and click on the checkout button.
        Fill in your billing and shipping information.
        Choose your preferred payment method.
        Review the total cost and confirm your purchase.
