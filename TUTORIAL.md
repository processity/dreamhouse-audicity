# Install and Run Audicity in the Dreamhouse Audicity Sample Application

_Tutorial (Duration 60 minutes)_

## Overview

Audicity is a native Salesforce app that uses the principles of observability to:

-   Record field data changes for as many objects and fields as needed.
-   Create end-to-end records of transactions (Audicity Span Events) that describe any actions that take place, or are invoked asynchronously by the transaction context.

Salesforce already can track field data changes with straightforward configurations using either Field History or Field Audit Trail. But each of these comes with limits on the number of tracked fields. And Field History limits history storage to two years. With Audicity, no such limits apply. There is more that can be said about this and the section [Audicity–Why Even?](#audicitywhy-even) goes into more detail about this later. But for now let’s get started with getting Audicity working.

In this tutorial, you will install, configure, and instrument code using Audicity's free trial. Once complete, you will have:

-   Installed Audicity.
-   Configured global settings for the org.
-   Configured tracking for two objects.
-   Captured and viewed a simple transaction.
-   Captured and viewed a complex transaction, including asynchronous Apex execution.

### Steps

-   [Getting Setup](#getting-setup)
-   [Quick Tour of Key Dreamhouse Features](#quick-tour-of-key-dreamhouse-features)
-   [Installing Audicity and Setting Up Your First Trace](#installing-audicity-and-setting-up-your-first-trace)
<!-- -   [Optional Reading on Audicity Architecture](#optional-reading-on-audicity-architecture) -->
-   [Expanding the Audicity Tracking Footprint](#expanding-the-audicity-tracking-footprint)

## Getting Setup

### Dependencies

This tutorial has dependencies on the following:

-   The Salesforce CLI
-   Visual Studio Code
-   The Salesforce Extension pack for VS Code
-   A non-production org to work with, typically a scratch org or a Developer edition org
-   The Audicity fork of the Dreamhouse sample application

Read on for a short description of each of these followed by guidance on where to find installation instructions for each. But if you are already familiar with developing on the Salesforce platform then feel free to [jump ahead](#installation-and-setup) into getting your org and the Dreamhouse sample application setup.

### Prerequisites

A Salesforce developer, or a very experience Salesforce administrator should be able to complete this tutorial. The skills that this tutorial expects are:

-   Git
-   Visual Studio Code
-   Apex
-   The Salesforce CLI

### Salesforce CLI

The Salesforce CLI is the command line tool for interacting with Salesforce environments, also known as orgs. You will use this to deploy the Dreamhouse and Audicity apps to your org.

### Visual Studio Code

Visual Studio Code (or VS Code) is Microsoft’s free and open source code editor, which is Salesforce’s supported code editor for developing on the Salesforce platform. While other IDEs exist for working with the Salesforce platform, this tutorial relies on VS Code.

> _**NOTE:** Salesforce Code Builder uses a hosted version of VS Code. While there is no reason this tutorial shouldn't work with Code Builder, it hasn't been tested with it. Additional steps may be required if you want to attempt this with Code Builder._

### Salesforce Extension Pack for VS Code

The Salesforce Extension Pack connects VS Code to your Salesforce orgs. The extension pack includes commands available through the command palette and context menus. There are also features like the org browser, test running and Einstein for Developers.

> _**NOTE:** Audacity requires some code be added to your org. This identifies when a transaction is starting and stopping. It also ensures asynchronous code can be attributed to an originating transaction._

### A Salesforce Org

While this tutorial could work in any org, the Dreamhouse app is designed to be a learning tool and not for production use. For the purposes of this tutorial we recommend only using either a developer edition Salesforce org or a scratch org. If you’re unfamiliar with either of these, using a developer edition org is the faster and easier way to get started.

### The Dreamhouse Sample Application

Dreamhouse is a sample application originated by the Salesforce developer relations team. The Audicity fork of the Dreamhouse app consists of a few additional features. It is called `dreamhouse-audicity`. These features provide additional context to someone learning how to install and configure Audicity as well as more interesting trace data than the standard Dreamhouse app might produce.

### Installation and Setup

1. The **Salesforce CLI** can be installed from the Salesforce Developers [website](https://developer.salesforce.com/tools/salesforcecli).
2. Instructions for **VS Code** and the **Salesforce Extension Pack** are found in the Extension Pack Developer [Guide](https://developer.salesforce.com/tools/vscode/en/vscode-desktop/install).
3. To create your **org** and install **`dreamhouse-audicity`** follow the steps in the `dreamhouse-audicity` [repo](https://github.com/processity/dreamhouse-audicity).

<!--
### Important Steps for Scratch Orgs

> _**Note:** Make sure to take note of the username of your Salesforce admin user. If you’re using a scratch org, you’ll need to generate a password to ease with the installation of the Audicity AppExchange package. An easy way to do both of these is using the Salesforce CLI from the dreamhouse-audicity directory._

_To generate a password_

```bash
> sf org generate password
```

_To view org details including username and password_

```bash
> sf org display
```
-->

## Quick Tour of Key Dreamhouse Features

### Dreamhouse and New Features

Dreamhouse has a number of custom features that were designed to show developers how to build features on the Salesforce platform. These consist of the Property object to track houses for sale and the Broker object, which represent the members of the Sales team. In the `dreamhouse-audicity` app, we’ve added some new features to illustrate Audicity's data history and tracing capabilities. These include:

-   A relationship field to the Property custom object in the Campaign object so that the property marketing team can run campaigns around properties that are being sold.
-   A trigger on the Property record called `PropertyTrigger` which ensures every property record has a main campaign for its promotions.
-   An Apex class called `PropertyTriggerHandler` which encapsulates much of the logic used by the Apex Trigger.
-   Two `Queueable` Apex classes that are used only when updates happen.
-   Modifications to page layouts, permission sets, and other necessary metadata so your Salesforce user can use and access these features.

Let’s see these in action.

### Create a new property record

Let’s get started. If you just setup the org you created for this tutorial, you may already be logged in. In which case, go to your org.

If not, you’ll need to login to your org again. You can do this using the Salesforce CLI command `sf org open` from your project directory. If you have a developer edition org, you can also go to [https://login.salesforce.com](https://login.salesforce.com) and use your username and password.

![entering SF org open from the command line and displaying the response message](https://github.com/user-attachments/assets/04f8e649-faf5-4a82-95e9-2fd17f24e952)

This will take you to your org. Typically you’ll find yourself in the setup menu. Although you might be in another location.

Let’s go find and try out the Dreamhouse app.

1. Click the App Launcher &nbsp;![waffle icon](https://github.com/user-attachments/assets/feb5ec4e-501f-4312-a2d3-bf86ab424de1).

<img src="https://github.com/user-attachments/assets/7f7e04a9-08c8-4a9d-a68d-0cdc6de3b722" alt="the app launcher waffle icon as viewed from the setup menu" width="210" height="97" ></img>

2. Click **View All**.

<img src="https://github.com/user-attachments/assets/4aee97e6-1acd-449b-b3ad-754c2290468c" alt="the app launcher menu with the view all link circled with a red line" width="338" height="443"></img>

3. Select **Dreamhouse**.

<img src="https://github.com/user-attachments/assets/f18dfc18-9135-4d75-a2a4-0a3e61762fe3" alt="the app launcher popup window with all of the app tiles visible and the Dreamhouse tile circled with a red line" width="1075" height="441"></img>

4. Click the **Properties** tab.

You’ll now see a list of property records. Let’s create a new one.

1. Click **New**.
2. Fill in the following values
    - **Name**: _Mid-Century Modern_
    - **Address**: _25 Peverell St_
    - **State**: _MA_
    - **Zip**: _02125_
    - **Status**: _Contracted_
    - **Asking** **Price**: _800000_
3. Click **Save**.

Along with the property record, a campaign was automatically created with a trigger. Let’s go find it.

1. On the property page, select the **Related** tab.
2. In the **Campaigns** related list, note the campaign record that was created. Click the campaign.
3. On the Campaign page, select the **Details** tab.

The new campaign record is derived from the property data. This includes the name, which is derived from the property name, and the **Expected Revenue in Campaign** field, which reflects the property’s asking price. The trigger also keeps things in sync as the property changes. Let’s go see:

1. Looking at the campaign record go to the **Property** field and click on the value _Mid-Century Modern_.

<img alt="the property field with the value mid-century modern" src="https://github.com/user-attachments/assets/c26d6d5d-f415-40bf-b09e-23e1e7adbba9"  width="451" height="57"></img>

2. Once back on the property page, change the following values
    - **Status**: _Available_
    - **Asking Price**: _825000_
3. Click **Save**.
4. Once again, click the **Related** tab.
5. Select the campaign record _Mid-Century Modern Main Campaign 2024-7_.
6. Click the **Details** tab.

The campaign record has been kept in sync with the changes in the property record.

### Reviewing the Dreamhouse Audicity App Functionality

Seeing two records kept in sync with Apex code is not cutting edge stuff. It is the bread and butter of Salesforce projects. But what if you want more visibility to the history of how things have changed? What if you have compliance requirements? What if you’re experiencing unexplained side-effects for certain transactions?

To answer these questions you might need to view historical field values, or even to be able to piece together a trace of what happened during transactions. This is where Audicity can help. Let’s get started and get Audicity installed.

## Installing Audicity and Setting Up Your First Trace

### Dreamhouse on Audicity

To comply with local fair housing regulation, the Dreamhouse org will be rolling out Audicity to ensure a full, complete, and permanent log of changes to important data in their org. They plan to roll this out initially to the Property object.

### Installing Audicity

In this tutorial, you’ll install the package using the Salesforce CLI.

You can install the Audicity package into your project org by going to the terminal in the project directory and entering

```bash
> sf package install --package Audicity --wait 5
```

It could take a couple of minutes for the install to complete, which will show the message below once successful. While you wait, you can read the [next section](#audicitywhy-even) which goes into more depth about Audicity’s two key benefits: field history tracking and transaction tracing.

```bash
Waiting 5 minutes for package install to complete.... done
Successfully installed package [Audicity]
```

> _**NOTE**: Audicity can also be installed directly from the AppExchange [listing](<[https://appexchange.salesforce.com/appxListingDetail?listingId=8ecf5cc2-cc0d-4292-9d22-ff5a73568828](https://appexchange.salesforce.com/appxListingDetail?listingId=8ecf5cc2-cc0d-4292-9d22-ff5a73568828)>). Audicity offers a free trial, but installation from AppExchange requires having a user with the `Manage Billing` user permission._

### Audicity–Why Even?

#### Extensive Data Change Tracking

If you’re experienced with Salesforce you may be asking yourself, “why can’t I just use the Field History?” After all, it’s free. Or if I’m paying for something why not use the Shield Field Audit History feature?

If your requirements are to track history for a limited number of fields, either of these features is a very good option.

Field History allows tracking for up to 20 fields, and the data is accessible for a maximum of two years. Field Audit History pushes the field limit to 100, and you get to keep your data forever (or at least as long as you pay for the Shield license). But what if strict compliance standards require you to track more than 100 fields? For such situations, a tool that can track as many fields as can be implemented in an object can completely remove such compliance headaches.

#### Understanding Transactions

And what about trying to get to the bottom of transaction problems, such as slow or unexpected results? Isn’t there the Apex log?

An Apex logging is user specific, has to be turned on and only stays active for a limited time. This can help in many instances. But intermittent or unpredictable failures can be difficult to diagnose under these circumstances. And even if you get your timing right, failures may not be obvious to find in large log files which can sometimes be truncated if too long.

The data that Audicity captures about all the work that is triggered by a transaction is called a _trace_. Once you’ve setup tracing, _all relevant_ transactions are traced. This makes it much more likely to capture data about a failure that happens intermittently.

To be clear: Audicity doesn’t trace all transactions. That might potentially be a lot\! Only the objects you’ve enabled will are traced. So there’s still no guarantee that you’ll capture that intermittent failure the first time when it takes place in the context of a non-traced object. But if you can pin down the failure to a particular object, you can then add tracing and you’ll be prepared for the next time a failure occurs.

### Configuring Access To Audicity

Tracking changes in your org requires access to potentially sensitive data. For this reason, Audicity is architected to use your configured Salesforce object, field, and sharing security settings. To ensure this security remains intact, Audicity features and data should only ever be granted via the Audicity permission sets and accessed through the Audicity UI.

Audicity is installed with a number of permission sets which are grouped into three user access levels using permission set groups. These are:

| Label                           | API Name                     |
| :------------------------------ | :--------------------------- |
| Audicity Tracking Administrator | AudicityLoggingAdministrator |
| Audicity Trace Viewer           | AudicityLoggingViewer        |
| Audicity Trace Writer           | AudicityLogWriter            |

The Audicity [user guide](https://docs.google.com/document/d/1oviP0r2l768R28MgBa_DOK1DvFve1hO0GCgwF3ZiZ3o/edit?usp=sharing) clearly outlines the permissions associated with each of these and when to use them. To complete this tutorial, you’ll need the _Audicity Tracking Administrator_ and _Audicity Trace Writer_ permission set groups.

> _**NOTE:** To ensure you do not accidentally expose sensitive data to the wrong users, we recommend a fully reading and understanding these three Audicity permission set groups before moving Audicity into any org where users might access real customer data, including production or full and partial copy sandboxes._

### Assign Permission Set Groups

Run the following command from the project in your terminal, or follow the UI instructions immediately after: :

```bash
> sf org assign permset --name AudicityLoggingAdministrator AudicityLogWriter
=== Permsets Assigned

 Username                      Permission Set Assignment
 ───────────────────────────── ────────────────────────────
 test-kist0stp1w36@example.com AudicityLoggingAdministrator
 test-kist0stp1w36@example.com AudicityLogWriter
```

#### UI Permission Set Group Assignment Instructions

1. Click the &nbsp;![gear](https://github.com/user-attachments/assets/0226307b-ed55-46f8-95d8-6f32f0045459)&nbsp; icon and select **Setup**.
2. Type _user_ in the **Quick Find** search field.
3. Select **Users**.
4. Find and click on your user record. If you’re using a scratch org, this is often named _User, User_.
5. Scroll down to find the **Permission Set Group Assignments** related list.
6. Click **Edit Assignments**.
7. Move _Audicity Tracking Administrator_ and _Audicity Trace Writer_ to the **Enabled Permission Set Groups** box.
8. Click **Save**.
9. Verify _Audicity Tracking Administrator_ and _Audicity Trace Writer_ now show in the **Permission Set Group Assignments** related list.

Congratulations\! You’ve successfully installed and given yourself access to Audicity. Time to get tracking\!

### Enable Audicity Tracking

For Audicity to begin to track changes in your org, there are a few steps which need to be completed.

-   Schedule Audicity Action Scheduler job.
-   Turn on Audicity.
-   For each object you track:
    -   Enabling tracking for objects.
    -   Specifying tracked fields.
    -   Adding the Audit Trail UI component to record pages.
    -   Instrumenting Apex code for traced objects.
-   Other required tasks are:
    -   Instrumenting Flow.
    -   Instrumenting Asynchronous Apex.

Time to turn on Audicity via the global configuration.

1. Click the App Launcher &nbsp;![waffle icon](https://github.com/user-attachments/assets/feb5ec4e-501f-4312-a2d3-bf86ab424de1).
2. Click **View All**.
3. Select **Audicity**.
4. Click the **Audicity Configuration** tab.
5. When first visiting Audicity Configuration, you’ll see a banner asking you to enable the _Audicity Action Scheduler_. Click **Schedule**.

<img alt="Audicity action scheduler banner" src="https://github.com/user-attachments/assets/25b68e9b-83ce-4499-93b3-e678c71dc6f5"></img>

6. Under **Global Configuration**, set **Tracking Status** to _Active_.
7. Click **Save**.

<img alt="tracking status toggle inactive" src="https://github.com/user-attachments/assets/d8e6227b-8030-4f8f-942c-eb1ffd691ac4" style="vertical-align: middle;"></img>
&nbsp;&nbsp;<img alt="greater than sign indicating next step in a process" src="https://github.com/user-attachments/assets/e15b418e-f294-400d-9f18-e4e7f0c0df46" style="vertical-align: middle;" height="34" width="35"></img>&nbsp;&nbsp;
<img alt="tracking status toggle clicked active but not saved" src="https://github.com/user-attachments/assets/7d28b75d-619c-4c2c-a99b-72c59ffad2f4" style="vertical-align: middle;">
&nbsp;&nbsp;<img alt="greater than sign indicating next step in a process" src="https://github.com/user-attachments/assets/e15b418e-f294-400d-9f18-e4e7f0c0df46" style="vertical-align: middle;" height="34" width="35"></img>&nbsp;&nbsp;
<img alt="save button" src="https://github.com/user-attachments/assets/6873e435-3e80-4762-8390-527ebaaeec74" style="vertical-align: middle;">
&nbsp;&nbsp;<img alt="greater than sign indicating next step in a process" src="https://github.com/user-attachments/assets/e15b418e-f294-400d-9f18-e4e7f0c0df46" style="vertical-align: middle;" height="34" width="35"></img>&nbsp;&nbsp;
<img alt="tracking status toggle with save in progress" src="https://github.com/user-attachments/assets/19992abd-7644-4af2-b08b-36d340dd9371" style="vertical-align: middle;">
&nbsp;&nbsp;<img alt="greater than sign indicating next step in a process" src="https://github.com/user-attachments/assets/e15b418e-f294-400d-9f18-e4e7f0c0df46" style="vertical-align: middle;" height="34" width="35"></img>&nbsp;&nbsp;
<img alt="tracking status toggle active and saved" src="https://github.com/user-attachments/assets/0e666828-8c83-42ba-b4ef-bae88699a1a3" style="vertical-align: middle;">

8. It can take a moment for tracking to be enabled.

Audicity is now enabled. Next you'll setup tracking on the first object.

> _**NOTE**: No changes are committed to the Audicity configuration unless explicitly saved. Be certain to commit any changes by clicking **Save** before leaving the Audicity Configuration tab. Any configuration changes are enabled asynchronously. The UI displays a warning icon and is locked from change while the save is in progress._
>
> <img alt="user interface displaying the in-progress warning icon" src="https://github.com/user-attachments/assets/39d1c92c-db2d-45f2-a9b7-923afd04efd0" height="188" width="284"></img>

### Enable the First Traced Object

To try out Audicity the Dreamhouse team will first roll out tracking on the Property Object.

1. You should already be in the **Audicity Configuration** tab. But if not, use the App Launcher &nbsp;![waffle icon](https://github.com/user-attachments/assets/feb5ec4e-501f-4312-a2d3-bf86ab424de1) to go to the **Audicity** app, and click **Audicity Configuration**.
2. The **Object Configuration** list should be empty. Click **Add Object**.

<img alt="the object configuration list with the add object button circled with a red line" src="https://github.com/user-attachments/assets/af78d676-a985-4328-9b49-4287e7574b2c" height="214" width="1000"></img>

3. Find the _Property_ object in the list of objects.
4. Click **+** on the row of the _Property_ object.
5. Click **Confirm**.
6. Click **Save** and wait a moment for the async update to complete.
7. The **Object Configuration** list should now show the _Property_ object with a status of _Active_.
8. On the _Property_ object row, click the ![pen icon](https://github.com/user-attachments/assets/42e65e98-380c-4476-b4f8-283a86c2b910) to edit the configuration.
9. Enable the following fields by clicking the **+** next to each row.
    - Asking Price
    - Broker
    - Date Agreement
    - Date Closed
    - Date Contracted
    - Date Listed
    - Price Sold
    - Status
10. Click **Confirm**.
11. The **Object Configuration** list should now show there are 8 tracked fields.
12. Click **Save** and wait a moment for the async update to complete.

Audicity now knows that you want to track an object and which fields to track. But there’s some work to do in order to send the right data to Audicity. This is called _instrumentation_, which is next.

### Instrumenting Your Object

Telling Audicity which fields to track is the first step. Audicity also requires some minor changes to your Apex code in order accurately trace the beginning and end of a transaction. This process is called instrumentation and is a common practice in the world of observability.

1. Open the `dreamhouse-audicity` project in Visual Studio Code.
2. Open the `PropertyTrigger` trigger file. You should see the following.

```apex
trigger PropertyTrigger on Property__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    // ***** Add your Audicity instrumentation code on the line immediately following this comment ******

    // ***** Add your Audicity instrumentation code on the line immediately before this comment ******

    PropertyTriggerHandler.handleTrigger(
        Trigger.new,
        Trigger.newMap,
        Trigger.oldMap,
        Trigger.operationType
    );

    // ***** Add your Audicity instrumentation code on the line immediately following this comment ******

    // ***** Add your Audicity instrumentation code on the line immediately before this comment ******

}
```

3. In between the first set of comments `PropertyTriggerHandler.handleTrigger()` add the following code:

```apex
   if (Trigger.isBefore){
       mantra.AudicityApex.track();
   }
```

4. In between the second set of comments add the following code block:

```apex
   if (Trigger.isAfter){
       mantra.AudicityApex.track();
   }
```

5. You can view a working version of the [completed](https://github.com/processity/dreamhouse-audicity/blob/complete-tutorial/force-app/main/default/triggers/PropertyTrigger.trigger) `PropertyTrigger` code in the `complete-tutorial` branch of the `dreamhouse-audicity` repo on GitHub.
6. From the menu bar select **File > Save**.
7. Right-click anywhere in the body of the trigger file and select **SFDX: Deploy This Source to Org** from the context menu.

Tracking is now enabled. You’re nearly there. With a quick adjustment to the UI of your object, you’ll be able to view the tracked data.

### Viewing Audicity Tracking in the UI

Audicity includes a web component which you can use to view the changes that Audicity tracks. It’s called the **Audit Trails** component. We’re going to add that to the Property record page using Lightning App Builder.

1. Click the App Launcher &nbsp;![waffle icon](https://github.com/user-attachments/assets/feb5ec4e-501f-4312-a2d3-bf86ab424de1).
2. Click **View All**.
3. Select **Dreamhouse**.
4. Select the **Properties** tab.
5. Select one of the property records from the list.
6. Click the &nbsp;![gear](https://github.com/user-attachments/assets/0226307b-ed55-46f8-95d8-6f32f0045459)&nbsp; icon at the top of the page and select **Edit Page** to open Lightning App Builder.
7. On the App Builder canvas in the middle, select the **Related** tab.

<img alt="property detail page in Lightning App Builder with related tab selected" src="https://github.com/user-attachments/assets/0dbe77da-afa6-4f02-9b37-f3b3dd338591"></img>

8. The component palette at the left contains all available components for this page. At the bottom is a grouping called **Custom Managed**. You should see the **Audit Trails** component there.

<img alt="component palette side bar in Lightning App Builder" src="https://github.com/user-attachments/assets/a6f2ea6c-7359-4d53-9ab6-fac5d474adc3" width="292" height="497"></img>

9. Drag **Audit Trails** onto the page just below the **Campaigns** related list.
10. Click **Save**.
11. Click the &nbsp;![left arrow](https://github.com/user-attachments/assets/a2d9d336-39b8-4ab0-964e-b658008fea73)&nbsp; at the upper left of the App Builder toolbar to go back to the Property record page.
12. Click the **Related** tab to verify the **Audit Trail** list is now visible.

<img alt="Audit Trail related list displayed in the property record detail page" src="https://github.com/user-attachments/assets/27dbeb35-bd62-4a97-bf06-a599665e577d" width="1000" height="754"></img>

Everything is now in place. You should now be able to track and view changes to the Property record.

### Testing Property Tracking

Let’s see the tracking on the Property object.

1. Click the **Properties** tab.
2. Click **New**.
3. Fill in the following values
    - **Name**: _Classic Tudor Styling_
    - **Address**: _103 Irving St_
    - **State**: _MA_
    - **Zip**: _02138_
    - **Status**: _Contracted_
    - **Asking Price**: _985000_
4. Click **Save**.
5. Modify the following fields
    - **Status**: _Available_
    - **Asking Price**: _1050000_
6. Click **Save**.
7. Select the **Related** tab.
8. In the **Audit Trail** related list you should now see two traces, one for record create and another for record update.

<img alt="Audit Trail related list displayed in the property record detail page" src="https://github.com/user-attachments/assets/73c70e48-4d15-4982-abac-09cd39860ddb" width="1000" height="248"></img>

9. Take a moment to click into each of these. Notice each contains the trace details, as well as the tree-like trace explorer. You’ll revisit this next with a more complex trace.

As you know, there is a trigger for Property which creates and keeps the Campaign record in sync. With a little more instrumentation and a small change to the Campaign UI, we can get a much richer picture of these Property save transactions.

<!--
TODO: Complete this section with architecture details about Audicity
## Optional Reading on Audicity Architecture, Tracing, Spans, ASEs, etc.

Section on About ASE’s and a bit about observability and how a “span” correlates to a transaction.

[Note: just had a thought how I could introduce a potential race condition where the trigger attempted to auto-update the “Listed” flag on Property…must investigate.]

[would like section in here explaining how Audicity works at a high level. Confining it to its own section means we could cue the learner to skip and come back if they wanted to. Alternatively, we could have a white paper or article that describes this that we summarize here and point them to.]
-->

## Expanding the Audicity Tracking Footprint

With the Property record tracking in place, we now want to get a more full picture of everything that happens with the property record is created or updated. Since we know the Campaign record is being affected, we can start by doing the setup for that object. Remember the steps are:

-   Configure the object
-   Instrument the trigger
-   Setup the record page

Since the update logic is implemented using asynchronous Apex, there will be an additional step to ensure that logic is instrumented.

### Track the Campaign Object

Once again you'll configure and instrument the object to track. In this instance, Campaign.

1. Click the App Launcher &nbsp;![waffle icon](https://github.com/user-attachments/assets/feb5ec4e-501f-4312-a2d3-bf86ab424de1) to go to the **Audicity** app.
2. Click **Audicity Configuration**.
3. In **Object Configuration** click **Add Object**.
4. Find the _Campaign_ object in the list of objects.
5. Click **+** on the row of the _Campaign_ object.
6. Click **Confirm**.
7. The **Object Configuration** list should now show the _Campaign_ object with a status of _Active_ along with the row previously configured for the _Property_ object.
8. On the _Campaign_ object row, click the pen icon to edit the configuration.
9. Set **Track All Fields** to _Yes_.
10. Click **Confirm**.
11. The **Object Configuration** list should now show _All Fields_ as tracked.
12. Click **Save**.
13. Once again, open (or return to) the `dreamhouse-audicity` project in VS Code.
14. Open the command palette by typing
    - In Windows: **CTRL-SHIFT-P**
    - In Mac: **COMMAND-SHIFT-P**
15. Type _Trigger_.
16. Select **SFDX: Create Apex Trigger**.

<img alt="SFDX new trigger command pallette action in VS code" src="https://github.com/user-attachments/assets/da8b2b4f-ea2c-4b06-bcc7-6663db7a998d"></img>

17. Type _CampaignTrigger_.
18. **Enter** to accept the default file path.
19. You should now have an empty Trigger code block in your new file. Copy and replace the entire code with the following:

```apex
trigger CampaignTrigger on Campaign(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    mantra.AudicityApex.track();
}
```

20. Once again, you can view the [completed](https://github.com/processity/dreamhouse-audicity/blob/complete-tutorial/force-app/main/default/triggers/CampaignTrigger.trigger) file in the GitHub repo.
21. **Save**.
22. Right-click in the body of your trigger code and select **SFDX: Deploy This Source to Org**.

    > _**NOTE**: Why is there one `track()` call in this trigger, while there were two in the previous example?_
    >
    > _Audicity expects an instrumentation call as close to the start of the transaction as possible. Likewise, another is expected to be as close to the end of the transaction as possible. In a trigger with no other logic, a single invocation ensures that on any operation (insert, update, etc.) there will be a `track()` call in each phase (before, after) of the transaction. When there is other logic invoked by a trigger, the `track()` call must be placed on either side of the start and end points of the execution of other logic. You can find more details on this in the Audicity User [Guide](https://docs.google.com/document/d/1oviP0r2l768R28MgBa_DOK1DvFve1hO0GCgwF3ZiZ3o/edit#heading=h.iw54etup6gvm)._

Everything is in place to track Campaign changes. But the Dreamhosue team also want more visibility into the asynchronous Apex calls that form the Campaign update logic. That's next.

### Trace Asynchronous Apex

As a general rule in Apex development, it’s important to not overload a single transaction. Asynchronous Apex is a useful tool to decouple some work to run in its own runtime context. But doing so also creates challenges when tracking data changes. Audicity traces can show how other features are invoked within the transaction, including asynchronous Apex.

Instrumenting asynchronous Apex is done in two places. First, when you invoke your asynchronous Apex and then, within the asynchronous Apex class itself.

> _**NOTE**: As of the publishing of this tutorial, the only asynchronous Apex that is supported is `Queueable`. Other types are on the roadmap._

1. Once again return to the project in VS Code.
2. Go to the `PropertyCampaignPriceUpdateQueueable.cls` Apex class.
3. Look for the `execute` method. There are two comment lines at the start of the method showing you where to put the code you need.
4. Add the call `mantra.AudicityAsync.track(context);` in between the two comment lines.
5. **Save** the file.
6. Repeat steps 2-5 with the `PropertyCampaignStatusUpdateQueueable.cls` Apex class.
7. Once complete, the first four lines of each of the execute method should look like this:

```apex
   public void execute(QueueableContext context) {
       // ***** Add your Audicity instrumentation code on the line immediately following this comment ******
       mantra.AudicityAsync.track(context);
       // ***** Add your Audicity instrumentation code on the line immediately before this comment ******
```

If you would like to see the full completed code with the Audicity instrumentation, you can see it on github for the [PropertyCampaignPriceUpdateQueueable](https://github.com/processity/dreamhouse-audicity/blob/complete-tutorial/force-app/main/default/classes/PropertyCampaignPriceUpdateQueueable.cls) class or the [PropertyCampaignStatusUpdateQueueable](https://github.com/processity/dreamhouse-audicity/blob/complete-tutorial/force-app/main/default/classes/PropertyCampaignStatusUpdateQueueable.cls) class.

The `PropertyTriggerHandler` is responsible for invoking these Queueable classes. You also need to instrument that code.

1. In VS Code, go to the `PropertyTriggerHandler.cls` class.
2. At the end of the class, there are two `if` statements.
3. Each of these enqueues one of the Queueable classes you just modified. Look for the comments that indicate where to put your instrumentation.
4. Add the call `mantra.AudicityAsync.track(jobId);` in between the two comment lines in each if statement.
5. **Save** the file.
6. Once complete the two if statements should look like this:

```apex
       if (propsUpdateStatus?.size() > 0) {
           PropertyCampaignStatusUpdateQueueable asyncStatus = new PropertyCampaignStatusUpdateQueueable(
               propsUpdateStatus
           );
           Id jobId = System.enqueueJob(asyncStatus);
           // ***** Add your Audicity instrumentation code on the line immediately following this comment *****
           mantra.AudicityAsync.track(jobId);
           // ***** Add your Audicity instrumentation code on the line immediately before this comment *****
       }


       if (propsUpdatePrice?.size() > 0) {
           PropertyCampaignPriceUpdateQueueable asyncPrice = new PropertyCampaignPriceUpdateQueueable(
               propsUpdatePrice
           );
           Id jobId = System.enqueueJob(asyncPrice);
           // ***** Add your Audicity instrumentation code on the line immediately following this comment *****
           mantra.AudicityAsync.track(jobId);
           // ***** Add your Audicity instrumentation code on the line immediately before this comment *****
       }
```

The complete PropertyTriggerHandler [code](https://github.com/processity/dreamhouse-audicity/blob/complete-tutorial/force-app/main/default/classes/PropertyTriggerHandler.cls) is also available on GitHub.

Commit these changes to your org.

1. Open the command palette with
    - In Windows: **CTRL-SHIFT-P**
    - In Mac: **COMMAND-SHIFT-P**
2. Type **deploy**.
3. Select **SFDX: Deploy This Source to Org**.

### Update the Campaign UI

Once again, we need to update the UI to see changes to the campaign object.

1. Click the App Launcher &nbsp;![waffle icon](https://github.com/user-attachments/assets/feb5ec4e-501f-4312-a2d3-bf86ab424de1)
2. In the field **Search apps and items…** type _Campaign_.
3. Select _Campaigns_.
4. Select any campaign record.
5. Click the gear icon at the top of the page and select **Edit Page**.
6. From the component palette, drag and drop the **Audit Trails** component to the bottom of the related list part of the page.
7. Click **Save**.
8. In the Activation popup click **Activate**.
9. Click **Assign as Org Default**.
10. Click **Next**.
11. Click **Save**.
12. Click the left arrow at the left of the App Builder toolbar to return to the campaign record page.
13. Note the Audit Trail component visible on the page.

### Test Audicity Transaction Traces

And with that, we’re ready! Let’s go make a change to one of our properties and see how that looks compared to before.

1. Click the App Launcher &nbsp;![waffle icon](https://github.com/user-attachments/assets/feb5ec4e-501f-4312-a2d3-bf86ab424de1).
2. Click **View All**.
3. Select **Dreamhouse**.
4. Click the **Properties** tab.
5. Select any property from the list.
6. Modify the **Status** and the **Asking Price** field values.
7. Click **Save**.
8. Select the **Related** tab.
9. Note a trace with a timestamp for when you last saved.
10. Click that trace to open the Audicity trace explorer.
11. Notice the additional details captured about the transaction.

<img alt="Audicity trace explorer displaying a complex trace containing clearly marked queue-able transaction branches" src="https://github.com/user-attachments/assets/9073a05c-cdc9-48e7-b6ef-9a2e8dd25b10" width="1000" height="306"></img>

Recall we defined a trace as all of the work performed by a transaction. Notice here the different branches that have been captured in this one trace.

As you click around and look at the transaction, you will find that the invocation of the queueable classes is clearly identified. If you search further into the tree, you will also find where updates took place in the campaign record related to this property record.

You could also go to the Campaign record which was modified and see its own trace history.

## Summary

In this tutorial, you’ve:

-   Installed the Audicity app.
-   Configured Audicity for operation
-   Setup two objects to be tracked with Audicity, including
    -   Set the object configuration
    -   Set the field configurations
    -   Added Apex instrumentation for the object
    -   Modified the record page for the object to show tracked changes
-   Instrumented some asynchronous Apex to be able to view how the transaction called the Queueable classes

Audicity is unmatched in its completeness of data tracking in Salesforce orgs. But beyond that, it can also be a useful tool to understand why certain changes were made to potentially assist with troubleshooting difficult to solve production problems.
