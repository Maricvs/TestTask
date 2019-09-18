require 'watir'

#b = Watir::Browser.new
#b.goto("https://my.fibank.bg/oauth2-server/login?client_id=E_BANK")

b = Watir::Browser.start "https://my.fibank.bg/oauth2-server/login?client_id=E_BANK"

sleep 5

b.link(id: 'demo-link').click

sleep 15
