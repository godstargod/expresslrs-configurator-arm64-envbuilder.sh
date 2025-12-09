
expresslrs-configurator-arm64-envbuilder.sh

script will setup Expresslrs-configurator on your pi5 cm511600 on ubuntu 25.10 
Once the installation complet successfully
You can run the app by navigating to ~/elrs/ExpressLRS-Configurator/release/linux-arm64-unpacked and running './expresslrs-configurator'.
npm run also works if all else fails (permission etc)



package.json --- backup and replace the publishing facility to a file instead of git 

because i didnt want to be bothered with publishing on git from the build i decided to include a strip version that will only create a .zip arm binary locally and not use git.  

you should backup your original package.json if you are to use the one provided instead or configure it yourself.






