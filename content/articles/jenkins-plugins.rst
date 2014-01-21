:title: Using Jenkins as the heart of developer workflow.
:date: 2014-02-21 13:37
:summary: A story of the Jenkins plugins we made at Paylogic
:category: Continuous Integration
:author: Maikel Wever
:slug: articles/jenkins-plugins
:tags: agile, continuous integration, release, testing, qa

*Most software developers will be familiar with the concept of peer-reviews and gatekeepering.
However, when working with many developers, this process (when done manually) can become quite time consuming.
This is why we wrote a few Jenkins plugins to do the work for us.*

What we were trying to achieve
------------------------------

Most of the work done here starts with a case in Fogbugz (an issue tracking system).
The idea is that a developer picks up a case, and starts developing the required features on a seperate branch.
This branch is then peer-reviewed, and later reviewed by designated gatekeepers.
When all is well, this feature branch then needs to be merged back into mainline, 
and sometimes even to previous releases to fix important live issues.

Until recently, this was a manual process done by the gatekeepers, which cost them loads of valuable time.
So we decided to automate this process. It will include merging, testing, and (if needed) upmerging of a feature branch.
This automated process must be administratable using Fogbugz, so we keep that as a central communication point.


A quick peek at Atlassian Bamboo
--------------------------------

Because one of the USPs of Bamboo is the Gatekeepering process, we decided to give that a try.
We wrote a plugin to report the status of builds back to Fogbugz, and tried to do upmerging there too.
Unfortunately, this resulted in failure, because we tried interfering with Bamboo's Gatekeepering, 
which rather defeated the point of using Bamboo in the first place.

This is when we decided to go back to Jenkins, because we had that already running for tests on our releases and developer repositories.


So, back to Jenkins
-------------------

We decided to implement the reporting, gatekeepering and mergekeepering process into Jenkins plugins, and release them open source (we love open source, who doesn't?).
To implement an extension to Jenkins, there are several 'extension points' to choose from. These are meant to be used with a corresponding class you extend,
and this way Jenkins figures out which classes of your package are plugins and which are not.

The main extension we used is the 'Builder' extension, meant for build steps in Jenkins.
Extending this class and annotating it with @Extension, you have one main method to implement, called 'perform'.

This method is what will be run during a Jenkins build, so here we implemented our Gatekeepering logic, 
in two builders: one for the merge itself, and one for comitting that merge.
The idea is that your tests run in between those builders, so you test the merged developer code. 
Because the buils is marked as a failure when the test fail, the gatekeeper commit will not run, and the workspace is reset at the beginning of the next build.


Providing information to the Gatekeeper builders
------------------------------------------------

We created an extra account on our Fogbugz instance, called 'Mergekeeper'. 
Whenever a case is assigned, Fogbugz sends a HTTP GET request to Jenkins, with the 'case id'.
This is then injected as a build parameter, and the build is scheduled.

For this we use environment variables. All data from a case is retrieved before the build, using a 'BuildWrapper' extension point.
This wrapper fetches the 'case id' from the build parameters, and uses that to retrieve the case which data it injects.

This data consists of:

- The 'target branch' (where the code will be merged to)
- The 'feature branch' or the path to a repository with a feature branch
- When working with seperate repositories, an 'approved revision', set on approvement by gatekeepers in the code review tool.


