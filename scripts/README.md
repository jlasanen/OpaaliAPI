# OpaaliAPI scripts

These are some scripts that I personally use when testing OpaaliAPI (see [http://developer.sonera.fi](http://developer.sonera.fi "Sonera Opaali Portal") ).

## Usage

First you need to get your service specific _username_ and _password_ (Check the document ***Opaali Portal Quick Guide*** in the [Resources](https://developer.sonera.fi/resources) Section of the Opaali Portal for more information.) Pass them to _create\_basic\_auth\_string.sh_ to get a *Base64* encoded BASIC_AUTH string: 


    $ ./create_basic_auth_string.sh 'b535b0c5e5ae815cea82db6b3b25059Cd' '1%AMCv?w'
        YjUzNWIwYzVlNWFlODE1Y2VhODJkYjZiM2IyNTA1OUNkOjElQU1Ddj93
    
----------

Then you should feed this to _get\_access\_token.sh to get the ***access\_token*** which is used in the rest of the API requests:

    
     $ ./get_access_token.sh YjUzNWIwYzVlNWFlODE1Y2VhODJkYjZiM2IyNTA1OUNkOjElQU1Ddj93
    3a66b3c8-3a34-423f-afb5-c7a425b17394


----------
Or more practically store it into a variable in a single-line command:

    $ access_token=`./get_access_token.sh \`./create_basic_auth_string.sh 'b535b0c5e5ae815cea82db6b3b25059Cd' '1%AMCv?w'\``


----------
Finally *send\_text\_message.sh* can be used to send a text message:

    $ ./send_text_message.sh $access_token from=12345 to=0401234567 msg="This is a test"
    {
      "resourceReference" : {
    "resourceURL" : "https://api.sonera.fi/production/messaging/v1/outbound/12345/requests/9d8af7c2-87fd-498e-a4f1-d307fcbd9638"
      }
    }
