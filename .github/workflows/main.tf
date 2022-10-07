name: ci

on:
  push:
    branches:
      - 'main'

jobs:
  continuous-integration:
    runs-on: ubuntu-latest
    steps:
      -
        name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      -
        name: Login to DockerHub
        uses: docker/login-action@v1 
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      -
        name: Set up Docker Buildx
        id: buildx
        uses: docker/build-push-action@v2
      -
        name: Build and push
        id: docker_build
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: dancairo/chat-app:latest
    
  continuous-deployment:
    runs-on: ubuntu-latest
    needs: [continuous-integration]
    steps:
     # Step 1
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }} 
          
      - name: Deploy to my EC2 instance
        uses: appleboy/ssh-action@master
        with:
          host: "ec2-3-80-40-175.compute-1.amazonaws.com"
          username: "ubuntu"
          key: ${{ secrets.EC2_SSH_KEY }}
          port: ${{ secrets.PORT }}
          script: |
           cd ezops-teste-dancairo
           sudo docker rm -f chat-app
           sudo docker pull dancairo/chat-app:latest
           sudo docker run -d --name=chat-app -p 8000:8000 --restart=always dancairo/chat-app:latest