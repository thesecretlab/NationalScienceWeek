// This file is released under the terms of the MIT License.
// Please see LICENSE.md in the root directory.

package au.net.scienceweek.scienceweek.network;

import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;

@Root(strict = false)
public class Venue {
	@Element(required=false)
	public String VenueName;
	@Element(required=false)
	public String VenueStreetName;
	@Element(required=false)
	public String VenueSuburb;
	@Element(required=false)
	public String VenuePostcode;
	@Element(required=false)
	public float VenueLatitude;
	@Element(required=false)
	public float VenueLongitude;
	@Element(required=false)
	public boolean VenueHasDisabledAccess;
}
