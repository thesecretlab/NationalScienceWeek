# National Science Week

This document describes the functional requirements for the National Science Week applications, and describes the data available from National Science Week that they work with.

## User Experience

This section outlines the user experience requirements for National Science Week apps.

### Overview

National Science Week is a collection of events that take place over the course of approximately a week. Users of the National Science Week apps want to do one of two things:

- Discover events they may be interested in
- Learn more about specific events
  
Secondarily, they may also want to learn more about National Science Week itself; this is a secondary concern, because it can be assumed that they know enough about it to have downloaded an app about it.

National Science Week is nation-wide, and events take place in every state and territory of the country.

As a result, the National Science Week apps make events the central focus of the experience. Users want to know what events are on, which events are near them, how to get to them, and when they are taking place.

### Screens

Existing National Science Week apps are structured like so:

- Top level
  - Event List
    - Event Details
  - Event Map
    - Event Details
  - General Information

#### Event List

The Event List screen displays a scrolling list of events taking place during National Science Week.

When the user selects an event, they are taken to the Event Details screen for that event.

Users can choose to view all events nation-wide, or filter the list to a specific state. (Filtering the list like this may be done with a popup, a separate screen, or with user interface elements present elsewhere in the screen.)

Users can search for specific events; text entered is matched against any text field in `Event` records that is intended to contain user-facing written language.

Users can filter the event to include only events they have marked as a 'favourite'.

Users can mark events as a 'favourite' from this screen.

On devices with large screen, such as tablets or large-screen phones in landscape orientations, this screen may be displayed as a master view, with the Event Details screen displayed next to it as a detail view.

#### Event Details

This screen displays information about an event. It is displayed in response to the user selecting an event from the Event List or Event Map screen.

The information about an event includes its name, description, location, and links to phone, email and the web.

Users can mark the current event as a 'favourite' from this screen.

#### Event Map

This screen displays a map of events, on a standard map view.

Users can select an event, and see a summary of its key information (generally its name; other information, like its start time or address, may be displayed at the application's discretion.)

There are a large number of events that take place during National Science Week, and displaying all events at the same is likely to be both cumbersome to the user and result in reduced performance. Applications are strongly encouraged to use marker clustering.

#### General Information

This screen displays general information about National Science Week itself. 

This screen generally displays a web view, pointed at a URL that either National Science Week provides, or we generate internally using copy provided by National Science Week. Any links present in the page should open in an external browser.

## Data

This section outlines the data structures used by the National Science Week system.

### General Notes

The data that drives the National Science Week apps is provided as an XML file. 

The most recent version of the file is available at the following URL: `http://www.scienceweek.net.au/event-transfer/scienceweek-events.xml`

This file is updated from time to time on the server. We have observed that National Science Week removes events that have finished from the file during the week itself.

The file is not guaranteed to be present when requested, and is not guaranteed to contain valid XML. Applications must be ready to handle this case. General robustness practices are strongly encouraged; cache the most recently retrieved version of the data, and fall back to this version upon failure. It is advisable to ship the app with a built-in copy of the data, retrieved at the time of the build.

Applications are encouraged to parse the raw XML data into an internal format, in order to improve performance.

The `scienceweek-events.xml` file is large (often over 1 megabyte in size, uncompressed), and should not be queried too often. It usually does not change more than once per 6 hours prior to National Science Week; however, during the week itself, last-minute urgent changes may arrive at any time, and these changes are expected to appear in the app as soon as possible. 

At the time of writing, the server does not compress the data, and sends it uncompressed.

Applications are strongly encouraged to make an HTTP `HEAD` request to the server to determine the file's `Last-Modified` value before downloading the file.

The data has no built-in support for repeating events. Events that take place over multiple days exist as duplicate copies, with the dates changed.

### Data structures

This section describes the data structures expected in the `scienceweek-events.xml` file.

The file contains a single root element: `Events`. This element contains zero or more `Event` elements. The order of these elements is undefined, and does not matter to the application.

#### `Event` record structure

|Field|Type|Description|Example|
|---|---|---|---|
|`EventID`|String|An internal ID number for the event. Not intended for display to the user. This ID may be assumed to be globally unique for each event.|SW45050|
|`EventName`|String|The name of the event.|Report-writing workshop for engineers and technologists|
|`EventType`|String|The type of the event. Not generally displayed to the user; usually just the string `Other`.|Other|
|`EventStart`|String|The start time and date of the event.|2016-08-16T09:30:00|
|`EventEnd`|String|The end time and date of the event.|2016-08-16T18:00:00|
|`EventDescription`|String|The description of the event.|This short but empowering course teaches the ins and outs of writing... (truncated for readability)|
|`EventTargetAudience`|String|The intended audience and age group of the event. This is a free-form text field.|Adults|
|`EventPayment`|String|A description of the kinds of payment accepted by the event.|$490 for the day, including workshop materials. Concessions available on request.|
|`EventIsFree`|boolean|`true` if the event is free; `false` if the event requires a ticket.|false|
|`EventCategory`|String|A string describing this event's category.|Science `&amp;` Technology ~ Archaeology and Antiquity|
|`EventContactName`|String|The name of the person that potential attendees should contact.|Carola de Keijzer|
|`EventContactOrganisation`|String|The name of the organisation that potential attendees should contact.|Workshops Worldwide|
|`EventContactTelephone`|String|The telephone number that potential attendees should contact. Not guaranteed to contain country code or state dialling code. May contain spaces or punctuation.|03 5429 1437|
|`EventContactEmail`|String|The email address that potential attendees should contact.|science-writing@inbox.com|
|`EventBookingEmail`|String|The name of the person that potential attendees should contact in order to make a booking. This may be different to the `EventContactEmail`.|science-writing@inbox.com|
|`EventBookingUrl`|URL|The URL that the user should visit in order to make a booking (Note the capitalisation of `Url`.)|http://scienceoutreachworkshops.weebly.com/science-week-report-writing.html|
|`EventSocialFacebook`|String|The Facebook contact information for this event. May be a URL or a Facebook username.|https://facebook.com/example|
|`EventSocialTwitter`|String|The Twitter contact information for this event. May be a URL or a Twitter username; usernames may or may not start with an `@`.|https://twitter.com/example|
|`EventBookingPhone`|String|The phone number to call in order to make a booking.|03 5429 1437|
|`EventWebsite`|URL|The URL that the user should visit in order to learn more about the event. This may be different to the `EventBookingUrl`.|http://scienceoutreachworkshops.weebly.com/science-week-report-writing.html|
|`EventState`|String|The Australian state that the event takes place in. One of the following values: `ACT`, `NSW`, `VIC`, `SA`, `NT`, `WA`, `TAS`.|VIC|
|`EventMoreInfo`|String|Additional information about the event.|Enter from Building 10 or Building 12.|
|`EventOfficialImageUrl`|URL|The location of an image to display for this event.|http://www.scienceweek.net.au/wp-content/uploads/2016/07/lightbulb_explosion_with_text.jpg|
|`Venue`|`Venue` data record|Information about the venue at which the event takes place.|_(see below)_|
|`Attractions`|Unknown|Unknown; possibly intended to be a list of especially interesting things at this event.|_(empty)_|

#### `Venue` record structure

|Field|Type|Description|Example|
|---|---|---|---|
|`VenueName`|String|The name of the location.|RMIT University
|`VenueStreetName`|String|The street address of the location. May or may not contain redundant infromation, like suburb and postcode.|Building 14, level 6 402 Swanston Street
|`VenueSuburb`|String|The suburb, municipality, and/or city in which the venue is located.|Melbourne
|`VenuePostcode`|String|The postcode in which the venue is located. Generally contains numeric data.|3000
|`VenueLatitude`|Float|The latitude of the location.|-37.808201
|`VenueLongitude`|Float|The longitude of the location.|144.9627511
|`VenueHasDisabledAccess`|Type|`true` if the location is accessible to disabled users; `false` otherwise.|false


#### Notes

- None of the elements in the XML are guaranteed to be present, or to contain data. In particular, the `EventContact` elements of `Event` records often only have a single element that is both present and non-empty, because most events just provide a single means of making a booking. Applications must treat all child elements in an `Event` as optional.
- Any String field may be multiple lines long. `EventDescription` and `EventTargetAudience` are especially prone to informal formatting, like the use of Unicode characters to create bulleted lists.
- Dates are formatted as `yyyy-MM-dd'T'HH:mm:ss`.
- Certain items may be escaped, due to it being XML; for example, ampersands (`&`) may appear as `&amp;`.
- Dates are in the local time of the location of the event, and should not be converted to different timezones.
- Emails, phone numbers and URLs should be parsed, and allow the user to interact with them. This could be in the form of a tappable text link, a button, or both.
- The contact details for an `Event` make a distinction between contact information and general event information. For each type of field (i.e. email, phone, URL), if they are both provided and they differ, present them both; otherwise, just present the first one that is non-empty.
- The `EventCategory` element may be present multiple times, indicating that an event is in multiple categories.
- The possible values of `EventCategory` have not been provided to us, and we've just been assuming they're for direct display.
- We've never seen any data in the `Attractions` element, and are unsure of its purpose. We've been ignoring it in all versions of the app.
- URLs may or 
- If an `Event` is missing an `EventIsFree` element, assume the value `false`.
- If a `Venue` is missing a `VenueHasDisabledAccess`, assume the value `false`.

#### Example XML

An complete example of an `Event` element, with its embedded `Value ` record, from the XML is as follows:

````xml
<Event>
    <EventID>SW45050</EventID>
    <EventName>Report-writing workshop for engineers and technologists</EventName>
    <EventType>Other</EventType>
    <EventCategory>Science &amp; Technology ~ Archaeology and Antiquity</EventCategory>
    <EventCategory>Science &amp; Technology ~ Energy and Transport</EventCategory>
    <EventStart>2016-08-16T09:30:00</EventStart>
        <EventEnd>2016-08-16T18:00:00</EventEnd>
    <EventDescription>This short but empowering course teaches the ins and outs of writing scintillating and easy-to-read reports on multiple scientific, technical and engineering topics. As part of the overall package, attendees may seek further advice and guidance by email or telephone for one month after the course. </EventDescription>
    <EventTargetAudience>Adults</EventTargetAudience>
    <EventPayment>$490 for the day, including workshop materials. Concessions available on request.</EventPayment>
    <EventIsFree>false</EventIsFree>
    <EventContactName>Carola de Keijzer</EventContactName>
    <EventContactOrganisation>Workshops Worldwide</EventContactOrganisation>
    <EventContactTelephone>03 5429 1437</EventContactTelephone>
    <EventContactEmail>science-writing@inbox.com</EventContactEmail>
    <EventWebsite>http://scienceoutreachworkshops.weebly.com/science-week-report-writing.html</EventWebsite>
    <EventState>VIC</EventState>
    <EventMoreInfo></EventMoreInfo>
    <EventBookingPhone>03 5429 1437</EventBookingPhone>
    <EventBookingUrl>http://scienceoutreachworkshops.weebly.com/science-week-report-writing.html</EventBookingUrl>
    <EventBookingEmail>science-writing@inbox.com</EventBookingEmail>
    <EventSocialFacebook></EventSocialFacebook>
    <EventSocialTwitter></EventSocialTwitter>
    <EventOfficialImageUrl>http://www.scienceweek.net.au/wp-content/uploads/2016/07/lightbulb_explosion_with_text.jpg</EventOfficialImageUrl>
    <Venue>
        <VenueName>Multicultural Hub</VenueName>
        <VenueStreetName>506 Elizabeth Street </VenueStreetName>
        <VenueSuburb>Melbourne</VenueSuburb>
        <VenuePostcode>3000</VenuePostcode>
        <VenueLatitude>-37.8069281</VenueLatitude>
        <VenueLongitude>144.9600735</VenueLongitude>
        <VenueHasDisabledAccess>true</VenueHasDisabledAccess>
        </Venue>
    <Attractions>
    </Attractions>
</Event>
````

## Version History

|Date|Description|
|---|---|
|9 June 2019|Initial version.|
