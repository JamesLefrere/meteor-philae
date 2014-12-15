#Philae

##An IRC bot for #meteor, created with Meteor!

If you have any complaints or requests, please let me know in the issues. It's just a bit of fun. 

It uses https://github.com/Pent/meteor-irc (I will submit a PR for my 1.0 version shortly!)

##Website

http://philaebot.meteor.com/factoids

##Usage

    Philae: JamesLefrere++  // Adds to JamesLefrere's karma
    karma JamesLefrere // Philae says, "JamesLefrere's karma is 1."
    Philae: love is don't hurt me... no more // Philae says, "Got it."
    Philae: what is love? // Philae says, "Love is don't hurt me... no more according to JamesLefrere."

If another user (SomeGuy) tells Philae what something is, it keeps both definitions:
  
    Philae: love is DOES NOT COMPUTE
    Philae: what is love? // Philae says, "Well, JamesLefrere says love is don't hurt me... no more. 
      SomeGuy says love is DOES NOT COMPUTE. Make of that what you will."
    
## Planned features

Seen

    Philae: seen lampe2 // Philae says, "lampe2 was last seen at 19:41 saying http://i.imgur.com/giCyafN.jpg"
    
