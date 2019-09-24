# to start working with Watir gem I need to require it
require 'watir'

# Line 5 launches the browser immediately with the bank interface,
# line 6 clicks on the banking demo page, because there is no direct link
  b = Watir::Browser.start "https://my.fibank.bg/oauth2-server/login?client_id=E_BANK"
  b.link(id: 'demo-link').click
  sleep 5
