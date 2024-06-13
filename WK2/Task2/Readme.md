### Docker Containers 

This task involves running an application in a docker conatiner and for this task i will be using a cloned aplication which can be found on the docker website:
[Docker APP](https://github.com/docker/getting-started-app/tree/main)


#### Steps

***LINK TO STEPS I FOLLOWED : [Build a Docker Container](https://docs.docker.com/get-started/02_our_app/)***
 - Clone the Repo into my working directory (This is a Node.js Application)
 ```
 git clone https://github.com/docker/getting-started-app.git
 ```

 - Build the Image by heading into the apps directory same path as the package.json file, then do the following steps:
    - Create a docker file - ```new-item -name DockerFile``` (This is a powershell command). 
    - I switched to wsl to use linux text editors by running ```wsl --install``` ![wsl installation](./Assets/wsl.png)
    - Edit the Docker file using:
    ```
      nano DockerFile

    

      FROM node:18-alpine   #gets a node 18 js image
      WORKDIR /app  #working directory of the container
      COPY . .     # copy all files from current directory to /app
      RUN yarn install --production   # install dependencies
      CMD ["node", "src/index.js"]    # run node src/index.js to start the app
      EXPOSE 3000                     # run on port 3000
    ``` 

    - Build the image ```sudo docker build -t getting-started .```. This involved downloading docker cli to my linux distro and I followed this steps [Install Docker on Ubuntu](https://docs.docker.com/desktop/install/ubuntu/). I had a few errors but ai just had to run the ```sudo apt-get update``` to get past.

    - On building i ran into an error ![Docker error](./Assets/docker.png). This is due to me using a capital ***F** to name my docker file instead of a small ***f*** . Renaming my file solved the issue.
    - Now I have an image and its time to create a container.


#### CREATING A CONTAINER 

 - Once the image has been created al lthat is left is to run the container using ```docker run -dp 127.0.0.1:3000:3000 getting-started```
 
         d- runs the container in the background
         p- creates a port mapping from 127.0.0.1 to localhost:3000 
- Once that was run I headed over to http://localhost:3000/ and was able to see the application.
![Working App](./Assets/WorkingApp.png)
![AppExample](./Assets/Examples.png)


#### STOPPING A CONTAINER 
 - Get a list of the running containers using the ```sudo docker ps ```
 - ```sudo docker stop <container id >```
 - ```docker rm <the-container-id>```
 ![Stop](./Assets/stopDocker.png)



 #### CREATIVE ASPECT USING VOLUMES

  - Created another to do app with a slight difference and created an image from it but exposed it to port 3001 intead of 3000
  -  Created a volume using the command ```docker volume create todo-db```
  - Then I ran the first container and mounted the volume to it.
  ```
  docker run -dp 127.0.0.1:3000:3000 --mount type=volume,src=todo-db,target=/etc/todos getting-started
  ```
  - This command starts up the container and saves any new todo item to the /etc/todos folder ***inside the container not your linux machine***
  - To connect to an existing/running container use the command 
  ```
  sudo docker exec -it <container name> /bin/sh
  ```
  I used this to make sure the /etc/todo file was actually created 
  - Next I ran the second image on another container and made the local host listen on port 3001
  ```
  sudo docker run -dp 127.0.0.1:3001:3000 --mount type=volume,src=todo-db,target=/etc/todos second-img
  ``` 

  ## IMAGE OF BTH RUNNING SIMULTANEOULSY USING THE SAME VOLUME  
  ![WORKING](./Assets/SIMULapp.png)

  Only drawback is you have to reload the page fo rthe second to get the updated todo list.