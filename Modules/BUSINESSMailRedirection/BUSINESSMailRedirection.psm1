

Set-Mailbox -ForwardingAddress 'local.sheppardind.co.nz/Sheppards/Users/Australia/Mulgrave Office/Steve Paraskevas' 
-Identity 'local.sheppardind.co.nz/Sheppards/Users/New Zealand/Auckland/Kim Struthers'



#Deliver to mailbox and forwared mailbox

Set-Mailbox -ForwardingAddress 'local.sheppardind.co.nz/Sheppards/Users/New Zealand/Auckland/Matthew Lyon' 
-DeliverToMailboxAndForward $true 
-Identity 'local.sheppardind.co.nz/Sheppards/Users/New Zealand/Auckland/Mark Struthers'



#just setting to send to both

Set-Mailbox -DeliverToMailboxAndForward $true 
-Identity 'local.sheppardind.co.nz/Sheppards/Users/New Zealand/Auckland/Kim Struthers'
