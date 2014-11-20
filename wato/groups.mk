# Written by WATO
# encoding: utf-8

if type(define_hostgroups) != dict:
    define_hostgroups = {}
define_hostgroups.update({'FR': u'FR perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'CA': u'CA perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'ES': u'ES perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'USCMS': u'USCMS perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'ITCMS': u'ITCMS perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'RU': u'RU perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'LHCOPN': u'LHCOPN perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'WLCG': u'WLCG perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'TW': u'TW perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'ITATLAS': u'ITATLAS perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'NL': u'NL perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'CERN': u'CERN perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'USATLAS': u'USATLAS perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'UK': u'UK perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'DE': u'DE perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Bandwidth': u'Bandwidth perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Latency': u'Latency perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'DE': u'DE perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Bandwidth': u'Bandwidth perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Latency': u'Latency perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'DE': u'DE perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Bandwidth': u'Bandwidth perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Latency': u'Latency perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'DE': u'DE perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Bandwidth': u'Bandwidth perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Latency': u'Latency perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'DE': u'DE perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Bandwidth': u'Bandwidth perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Latency': u'Latency perfSONAR-PS Toolkit nodes'})
define_hostgroups.update({'Bandwidth': u'Bandwidth perfSONAR-PS Toolkit nodes',
 'CA': u'CA perfSONAR-PS Toolkit nodes',
 'CERN': u'CERN perfSONAR-PS Toolkit nodes',
 'CZ': u'perfSONAR-PS Toolkit nodes from CZ',
 'DE': u'DE perfSONAR-PS Toolkit nodes',
 'ES': u'perfSONAR-PS Toolkit nodes from ES',
 'FR': u'perfSONAR-PS Toolkit nodes from FR',
 'GB': u'perfSONAR-PS Toolkit nodes from GB',
 'IT': u'perfSONAR-PS Toolkit nodes from IT',
 'ITATLAS': u'ITATLAS perfSONAR-PS Toolkit nodes',
 'ITCMS': u'ITCMS perfSONAR-PS Toolkit nodes',
 'LHCONE': u'LHCONE perfSONAR-PS Toolkit nodes',
 'LHCOPN': u'LHCOPN perfSONAR-PS Toolkit nodes',
 'Latency': u'Latency perfSONAR-PS Toolkit nodes',
 'ND': u'ND perfSONAR-PS Toolkit nodes',
 'NL': u'NL perfSONAR-PS Toolkit nodes',
 'PT': u'perfSONAR-PS Toolkit nodes from PT',
 'RO': u'perfSONAR-PS Toolkit nodes from RO',
 'RU': u'perfSONAR-PS Toolkit nodes from RU',
 'TW': u'TW perfSONAR-PS Toolkit nodes',
 'UK': u'UK perfSONAR-PS Toolkit nodes',
 'US': u'perfSONAR-PS Toolkit nodes from US',
 'USATLAS': u'USATLAS perfSONAR-PS Toolkit nodes',
 'USCMS': u'USCMS perfSONAR-PS Toolkit nodes',
 'WLCG': u'WLCG perfSONAR-PS Toolkit nodes'})

if type(define_servicegroups) != dict:
    define_servicegroups = {}
define_servicegroups.update({'Bandwidth': u'Bandwidth Test Controller',
 'NDT': u'Network  Diagnostic  Tester',
 'NPAD': u'Network Path and Application Diagnosis',
 'OWAMP': u'One-Way Ping Service OWAMP',
 'PS-Admins': u'PS Toolkit Administrator Configured, cached and checked every hour',
 'PS-Homepage': u'PS-Homepage access checked every 6 hours(port 443)',
 'PS-Homepage-No-Cert': u'PS-Homepage access checked every 6 hours(port 80)',
 'PS-LatLong': u'PS Toolkit Latitude/Longitude Configured, cached and checked every hour',
 'PS-Location': u'PS Toolkit Location Configured, cached and checked every hour',
 'PS-Version': u'PS Toolkit Version, cached and checked every hour',
# Deprecating 07Jun2014
# 'PingER': u'PingER Measurement Archive',
 'TracerouteMA': u'Traceroute Measurement Archive',
 'WLCG-Mesh-Updates': u'Check for WLCG mesh updates',
 'perfSONAR-BUOY-MA': u'perfSONAR-BUOY  Measurement  Archive'})

if type(define_contactgroups) != dict:
    define_contactgroups = {}
define_contactgroups.update({'all': u'Everybody'})


