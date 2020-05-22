#!/bin/bash
# Process properties.csv to get property tags
cat << END_HEADER > PropertyTags.java
// DO NOT EDIT THIS FILE
// Automatically generated on $(date) by pstreader/extras/getpropertytags.sh
// Any changes must be made to that file.
package io.github.jmcleodfoss.pst;

/** Known Property tags
*	@see <a href="https://github.com/Jmcleodfoss/pstreader/blob/master/extras/properties.csv">pstreader properties.pst</a>
*	@see <a href="https://github.com/Jmcleodfoss/msgreader/blob/master/extras/getpropertytags.sh">getpropertytags.sh</a>
*	@see <a href="https://docs.microsoft.com/en-us/openspecs/exchange_server_protocols/ms-oxprops/f6ab1613-aefe-447d-a49c-18217230b148">MS-OXPROPS</a>
*/

public class PropertyTags
{
	// Properties related to named properties. These are defined in MS-PST rather than in MS-OXPROPS.
	static final int NameidBucketCount = 0x0001;
	static final int NameidStreamGuid = 0x00020102;
	static final int NameidStreamEntry = 0x00030102;
	static final int NameidStreamString = 0x00040102;
	static final int NameToIdMapBucketFirst = 0x1000;
	static final int NameToIdMapBucketLast = 0x2fff;

	static final int NamedPropertyFirst = (short)0x8000;
	static final int NamedPropertyLast = (short)0x8fff;

END_HEADER
sort -t , -k 2 properties.csv | sed '
	${
		i\

		i\
	static final java.util.HashMap<Integer, String> tags = new java.util.HashMap<Integer, String>();
		i\
	static {
		i\
		tags.put(NameidStreamGuid, "Named Property GUID Stream");
		i\
		tags.put(NameidStreamEntry, "Named Property Entry Stream");
		i\
		tags.put(NameidStreamString, "Named Property String Stream");
		g
		a\
	}
	}

	/\(PidTag\)\(7BitDisplayName\)/s//\1_\2/
	/^PidTag\([^,]*\),\([^,]*\),\([^,]*\),0x\(.*\),,$/s//\	static final public int \1 = \2\4;/p
	/^.*static final public int \([^ ]*\).*$/{
		s//\	\	tags.put(\1, "\1");/
		H
		d
	}
	/n\/a/d
	/^PidLid/d
	' >> PropertyTags.java

cat << END_FOOTER >> PropertyTags.java

	static String name(int tag)
	{
		if (tags.keySet().contains(tag))
			return tags.get(tag);
		return String.format("propertyTag-%08x", tag);
	}

	public static void main(String[] args)
	{
		java.util.Iterator<Integer> iter = PropertyTags.tags.keySet().iterator();
		while (iter.hasNext()) {
			Integer t = iter.next();
			System.out.printf("0x%08x: %s\n", t, PropertyTags.tags.get(t));
		}
	}
}
END_FOOTER
