# EasyMetaHub Accelerator for an eXist-db project

There a many projects out there that do not require the power of MarkLogic and the licensing fees for it as well.  
[http://history.state.gov](http://history.state.gov) is one such project.  It has been using eXist-db as its hosting platform.

This is a starting point for most search programs.  It is a general purpose viewer for SKOS taxonomies.

Download a release candidate for version 5 of eXist-db from here: 
[https://bintray.com/existdb/releases/exist/5.0.0-RC7/view](https://bintray.com/existdb/releases/exist/5.0.0-RC7/view)

The basic installation and getting started is here:

[http://exist-db.org/exist/apps/doc/basic-installation](http://exist-db.org/exist/apps/doc/basic-installation)

The initial view when you open your browser to 
[http://localhost:8080](http://localhost:8080) is:

![images/eXist-start.png](images/eXist-start.png)

Click login and usee the username admin with no password.

![images/login.png](images/login.png)

You will then see the page 

![images/launcher-1.png](images/launcher-1.png)

Select the 'Package Manager'

![images/package-manager.png](images/package-manager.png)

Click on 'Upload' and select emh-accelerator-1.0.0.xar

![images/package-upload.png](images/package-upload.png)

The EMH Accelerator shows up in the installed list.

![images/package-manager-2.png](images/package-manager-2.png)

Select 'Launcher' and the EMH Accelerator shows up in the list of applications.

![images/launcher-2.png](images/launcher-2.png)

Click on the accelerator:

![images/emh-accelerator-1.png](images/emh-accelerator-1.png)

Click on the upload button

![images/emh-accelerator-2.png](images/emh-accelerator-2.png)

Click on 'upload files' and select IVOAT.rdf or drag the file onto the upload dialog.

![images/emh-accelerator-3.png](images/emh-accelerator-3.png)

![images/emh-accelerator-4.png](images/emh-accelerator-4.png)

Close the dialog and you will get this:

![images/emh-accelerator-5.png](images/emh-accelerator-5.png)

Type *Galaxy* in the search bar.

![images/emh-accelerator-6.png](images/emh-accelerator-6.png)

You can then select a facet to narrow the search results.  You can also expand a result item by selecting *Show Details*

![images/emh-accelerator-7.png](images/emh-accelerator-7.png)

If you select one of the buttons for *Related*, *Broader*, or *Narrower*, then you will be hyperlinked to that *Concept*

![images/emh-accelerator-8.png](images/emh-accelerator-8.png)


The customizations for this project template are in:


- src/main/xquery/modules/custom/custom.xqm
- src/main/resources/collection.xconf
- src/main/polymer/src/emh-accelerator-app/result-item.js
