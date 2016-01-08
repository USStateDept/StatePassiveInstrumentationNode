# StatePassiveInstrumentationNode
State Passive Instrumentation Node (SPIN)

Philip Tong of US Consulate Hong Kong is credited with popularizing the code that has become SPIN - State Passive Instrumentation Node - or just sometimes Dashboard.

The dashboard is an .ASP script that runs on your webserver and provides basic information in a single glance about the status of your servers, your network - switches, circuits, etc.

We are working on getting more documentation, general data, etc. Feel free to contribute!

_____________________________________________________________________
For SPIN to work: 

1) Install into your webroot dir on your webserver and create a website for it.

2) Please use the local GP editor to add the domain\Iuser account to each server's local security policies as follows:

    access this computer from the network
    adjust memory quotas fro a process
    Allow logon on locally
    Generate security audit
    Impersonate a client after authentication
    logon as a batch job
    logon as a service
    replace a process level token
<br>
Make certain that your app pools are also using the domain\iusr account, and not the local servers.
