# Étape 1 : Construction
FROM node:20.11.1-alpine3.19 AS builder

# Définir le répertoire de travail
WORKDIR /opt/app

# Copier les fichiers nécessaires pour installer les dépendances
COPY package.json yarn.lock ./

# Installer node-gyp et les dépendances nécessaires
RUN yarn global add node-gyp && yarn config set network-timeout 600000 -g && yarn install

# Copier le reste des fichiers du projet
COPY . .

# Construire l'application
RUN yarn build 

# Étape 2 : Image finale
FROM node:18.16.0-alpine

# Installer les dépendances nécessaires pour exécuter l'application
RUN apk update && apk add --no-cache vips-dev && \
  rm -rf /var/cache/apk/*

# Définir le répertoire de travail
WORKDIR /opt/app

# Copier les fichiers nécessaires depuis l'étape de construction
COPY --from=builder /opt/app .
COPY --from=builder /opt/app/node_modules ./node_modules

# Ajouter un volume pour la Media Library
VOLUME /opt/app/public/uploads

# Définir le port d'exposition
EXPOSE 1337

# Lancer l'application
CMD ["yarn", "start"]
