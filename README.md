## Welcome to FairPlay Gaming

FairPlay Gaming is a gaming community created in December 2010. We enjoy playing games without limits and we try to push our community forward by having fun and searching new unique ways to expand our community to more games for more people. You are more than welcome to our community and we hope that you will enjoy your stay with us!

### Gamemode introduction

This is a Multi Theft Auto Roleplay gamemode, designed specifically for FairPlay Gaming.

**Please note**, that this is in development, and should not be used for anything yet! You can mark issues and make pull requests. This script is missing some features, which is exactly why this should not be used yet.

### Installation and setup

1. **Clone the repository.** Clone the repository to your Multi Theft Auto folder through your favoured Git program, if you do not yet have a Git program I highly recommend you get one, or otherwise you will not be able to make changes on your computer (except online on GitHub, which is a bit difficult at times). You can find a list of a few Git programs below.

2. **Set up database configuration.** Set up your database configuration in `database/meta.xml` settings.

3. **Start the Multi Theft Auto server.** You now have a full copy of the repository on your computer. With this copy you should now be able to run your server.

4. **Join your local server.** After you started your Multi Theft Auto server you are now able to play on it. Your server has automatically initialized all the resources just like on the live server.

5. **You are ready to go.** Now I would say you are pretty much done! You can now develop on your local server and make changes to the resource files as much as you want. You do not need to push through the Git server each time you make a commit necessarily, but even if you do, it is easy since all changes are automatically subscribed on to your local Git copy. This helps you do your work faster and more efficiently!

### Quick start

#### Starting via F8 console

`srun resources = { "security", "database", "common", "messages", "accounts", "admin", "realism", "items", "inventory", "chat", "vehicles", "factions", "scoreboard", "superman" } for _, resource in ipairs( resources ) do startResource( getResourceFromName( resource ) ) end`

#### Starting via mtaserver.conf

`<resource src="security" startup="1" protected="0" />
<resource src="database" startup="1" protected="0" />
<resource src="common" startup="1" protected="0" />
<resource src="messages" startup="1" protected="0" />
<resource src="accounts" startup="1" protected="0" />
<resource src="admin" startup="1" protected="0" />
<resource src="realism" startup="1" protected="0" />
<resource src="items" startup="1" protected="0" />
<resource src="inventory" startup="1" protected="0" />
<resource src="chat" startup="1" protected="0" />
<resource src="vehicles" startup="1" protected="0" />
<resource src="factions" startup="1" protected="0" />
<resource src="scoreboard" startup="1" protected="0" />
<resource src="superman" startup="1" protected="0" />`

#### Starting via **initializer**

##### F8 console
`srun startResource( getResourceFromName( "initializer" ) )`

##### mtaserver.conf
`<resource src="initializer" startup="1" protected="1" />`

### Git programs

There are several Git programs that give you the ability to clone a remote repository to your local machine. You should see the up -and downsides of each program individually and see which one is the best fit for you and your use.

* **[GitHub for Windows](https://windows.github.com/), [GitHub for Mac](https://mac.github.com/).** This is GitHub's native Git program. It comes with the best core functionality on the UI, but also installs you a command line application so you can test out both and decide which one is for you. You log in with your GitHub credientials and start doing some fancy commits!
* **[SourceTree](http://www.sourcetreeapp.com/).** Not necessarily one of the best tools for beginners, but does its thing. The UI is a little bit messy as they tried to tuck in all Git functionality (even the slightest ones). But if you feel like SourceTree fits your class, feel free to do that!
* **[Tower](http://www.git-tower.com/).** Tower is a rather easy to use and well made Git tool. You can do all of the things you need, pretty much the same way as on GitHub for X. The only downside for this tool is, that it has a 30-day trial until it becomes necessary for you to purchase the full version.

If you feel that you only just want to use the very basic command line version, you may do that as well. Download Git through [Git's official site](http://git-scm.com/) and get started!

### Official repository introduction

This is the official Multi Theft Auto repository of FairPlay Gaming. We synchronize all files through Git, specifically GitHub, so that all contributors can list and find all commits and files for easier use. We do not use FTP to modify files, but instead work with local copies of the gamemode and after we are satisfied we push the commits to the live server. This way we do not have to bother other players with constant updates and bugs.

Git is also a good tool for keeping up data on different versions, branches and such. With Git we are able to push commits and each commit is its own "revision". If we want to, we can always create a branch for a specific incoming update. We can batch specific system(s) into that branch and later merge it with the master copy when we feel that it is ready to go for a release version.

We are not able to push commits directly on to the server through Git. The reason why this is not possible is that we are running on a dedicated game server machine and I do not possess any privileges for installing and setting up Git programs. We could potentially be able to use command line to update the local Git repository copy on the server, so that all updates would be pulled and when we hit 'refreshall', it would reload all of the changed resources. This system is something I would love to get to know better and I hope we can manage this later if we ever do, and if ever purchase and set up a virtual private server.

With Git all contributors have the same data, same files and pretty much same version of everything. If all contributors opened one single file and started making changes to it in different spots, these changes would not cause overwriting problems. If we used FTP, we would all make changes to the single file, but as there is no "file synchronization handler", the file is always overwritten to the version, which the owner has at the very moment it is pushed on to the server. Git on the other hand specifically looks for actual changes and pushes those accordingly to all known versions so, that the actual file is never overwritten by accident. So it never actually pushes a full file, but just that one typographical fix you made - that, is just awesome.

You also do not need internet connection to make changes. You can do local changes at any place at any time, and when you do have access to internet you can see the recent changes if any, and push to the server accordingly. This way you can work anywhere, and then later save it to "the cloud", and by cloud I mean, that your work is saved on a different machine somewhere else in the world. This way if your hard drive is lost, you should always be able to pull that one last commit via Git, hooray!

If all of this still seems a little bit fuzzy for you, feel free to [check out a web-based test on Git](https://try.github.io/)!
