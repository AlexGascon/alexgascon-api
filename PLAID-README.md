## Connecting with Plaid
This document contains information about the steps to follow to renew Plaid tokens, as these expire every few months.

### 1 - Obtain a new link token
The first step is to use your access token (stored as a AuthToken object) to get a new link token

The steps can be found here: https://plaid.com/docs/link/update-mode/

For simplicity, you can just use the following snippet after replacing the corresponding variables

```ruby
plaid = Finance::PlaidClientFactory.build

link_token_create_request = Plaid::LinkTokenCreateRequest.new({
    :user => { :client_user_id => 'CLIENT_ID_HERE' }, # Obtainable from Plaid control panel
    :client_name => 'My App',
    :access_token => 'ACCESS_TOKEN_HERE', # Obtainable from AuthToken table
    :country_codes => ['IE'],
    :language => "en",
    :webhook => 'https://webhook.sample.com'
})

response = plaid.link_token_create(link_token_create_request)

puts "Link token: #{response.link_token}"
```

### 2 - Use the link token to renew the credentials validity
The next step is to use the link token to extend the validity of your credentials. You will need to use it to make your customer introduce their and give you permission again

You can easily do so with the following HTML page:

```html
<button id="link-button">Link Account</button>
<script src="https://cdn.plaid.com/link/v2/stable/link-initialize.js"></script>

<script type="text/javascript">
(async function() {
  const fetchLinkToken = async () => {
    return 'YOUR_LINK_TOKEN_HERE'
  };
  const configs = {
    // 1. Pass a new link_token to Link.
    token: await fetchLinkToken(),
    onSuccess: async function(public_token, metadata) {
      console.log("PUBLIC TOKEN: " + public_token);
      console.log("metadata: " + metadata);
    },
    onExit: async function(err, metadata) {
      // 2b. Gracefully handle the invalid link token error. A link token
      // can become invalidated if it expires, has already been used
      // for a link session, or is associated with too many invalid logins.
      if (err != null && err.error_code === 'INVALID_LINK_TOKEN') {
        console.log("INVALID_LINK_TOKEN")
      }
      if (err != null) {
        console.log("OTHER ERRORS")
      }
    },
  };

  var linkHandler = Plaid.create(configs);
  document.getElementById('link-button').onclick = function() {
    linkHandler.open();
  };

})();
</script>
```

**NOTE: this won't work if you just open an HTML file with a web browser**. You need to serve it from an HTTP server

You can do so easily with Python. 

1. Save the previous HTML in a file called `plaid-token-renew.html`
1. Open a terminal session, go to the folder where this file is located, and run `python3 -m http.server`
1. In your web browser, go to http://localhost:8000/plaid-token-renew.html 
1. Click on the "Link account button", and follow all the authentication steps

At the end of the process, your access token will be valid again. **YOU DON'T NEED TO DO ANY ADDITIONAL STEP AFTER AUTHORIZING YOUR BANK CREDENTIALS**, the previous access token will still be valid. You don't need to get a new one.

