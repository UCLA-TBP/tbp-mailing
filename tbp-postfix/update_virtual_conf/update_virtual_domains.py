#!/usr/bin/env python
import sys, re
import os

sys.path.insert( 0, '/app' )

from tbpsite import settings
from django.core.management import setup_environ

from datetime import date

setup_environ( settings )

from django.db.models import Q
from main.models import Officer, ActiveMember, Settings, Profile, House, Candidate

if not os.path.exists('/etc/postfix_conf/restrict_classes'):
    os.makedirs('/etc/postfix_conf/restrict_classes')

# Officers' position-specific emails
aliases = {}
copy_emails = { 'ucla.tbp@gmail.com'}
officer_emails = set() | copy_emails
for position in Officer.objects.all():
    position_emails = copy_emails | {
            officer.user.email for officer in position.profile.all() }
    officer_emails |= position_emails
    if position.mail_alias:
        aliases.setdefault( '%s@tbp.seas.ucla.edu' % position.mail_alias, set()
             | position_emails )

officer_aliases = aliases.keys()

aliases[ 'officers@tbp.seas.ucla.edu' ] =  officer_emails
# Static entries
with open( '/etc/postfix_conf/virtual_static', 'r' ) as f:
    lines = f.read()
    for line in lines.split( '\n' ):
        if not line or line[ 0 ] == '#':
            continue

        alias, targets = line.split( '\t' )
        targets = [ t.strip() for t in targets.split( ',' ) ]

        aliases.setdefault( alias.strip(), set() ).update( set( targets ) )

# Distinguished actives
for da in ActiveMember.current.all():
    aliases.setdefault( 'dist.actives@tbp.seas.ucla.edu', []
        ).add( da.profile.user.email )

# Candidates and houses (candidates and DA's ONLY, all others are static entries)
houses = {}
houseLeaderAliases = []
cand_houses = {}

for house in House.HOUSE_CHOICES:
    houses[ house[ 0 ] ] = '%s.house@tbp.seas.ucla.edu' % house[ 1 ].lower()
    cand_houses[ house[ 0 ] ] = '%s.candidates@tbp.seas.ucla.edu' % house[ 1 ].lower()

candidate_emails = set()

for candidate in Candidate.objects.filter(term=Settings.objects.term()):
    candidate_emails.add(candidate.profile.user.email)
    if not candidate.profile.house:
        continue

    aliases.setdefault( houses[ candidate.profile.house.house ], set() ).add( candidate.profile.user.email )
    aliases.setdefault( cand_houses[ candidate.profile.house.house ], set() ).add( candidate.profile.user.email )


aliases.setdefault( 'candidates@tbp.seas.ucla.edu', set())
aliases['candidates@tbp.seas.ucla.edu'] |= candidate_emails
aliases.setdefault( 'tbp_candidates@tbp.seas.ucla.edu', set())

for da in ActiveMember.objects.all():
    if not da.profile.house:
        continue
    aliases.setdefault( houses[ da.profile.house.house ], set() ).add( da.profile.user.email )

member_emails = set()
# Members that havent graduated and have initiated
for member in Profile.current.filter(position = Profile.MEMBER):
    member_emails.add(member.user.email)


aliases.setdefault( 'members@tbp.seas.ucla.edu', set())
aliases['members@tbp.seas.ucla.edu'] |= member_emails
aliases.setdefault( 'tbp_members@tbp.seas.ucla.edu', set())

# adds copy emails to everyone besides personal emails
for key in aliases:
    aliases[key] |= copy_emails


# Personalized officer emails
officers = set()
for position in Officer.objects.all():
    for officer in position.profile.all():
        officers.add(officer)

for officer in officers:
    first_name_alias = "%s@tbp.seas.ucla.edu" % officer.user.first_name.lower().replace(" ", "")
    aliases.setdefault(first_name_alias, [])
    aliases[first_name_alias].append(officer.user.email)

    long_alias = "%s.%s@tbp.seas.ucla.edu" % (officer.user.first_name.lower().replace(" ", ""), officer.user.last_name.lower().replace(" ", ""))
    aliases.setdefault(long_alias, [])
    aliases[long_alias].append(officer.user.email)

    if officer.nickname:
        nickname_alias = "%s@tbp.seas.ucla.edu" % (officer.nickname.lower().replace(" ", ""))
        aliases.setdefault(nickname_alias, [])
        aliases[nickname_alias].append(officer.user.email)

# Turn alias dict into postfix format
aliasStr = '# DO NOT CHANGE THIS FILE. MAKE CHANGES TO /etc/postfix/virtual_static INSTEAD.\n'
vmail_str = '# DO NOT CHANGE THIS FILE. ALTERATIONS MADE THROUGH update_email_aliases.py\n'
for alias, targets in aliases.items():
    vmail_addr = alias.replace('tbp.seas.ucla.edu', 'vmailbox')
    aliasStr += '%s\t%s%s\n' % ( alias, ', '.join(sorted(filter(lambda x: x.strip(' '), targets))), ', ' + vmail_addr)

    box_name = alias.replace('@tbp.seas.ucla.edu', '')
    vmail_str += '%s\t%s/\n' % (vmail_addr, box_name)

# Commit aliases to virtual file
with open( '/etc/postfix_conf/virtual', 'w+' ) as f:
    print >>f, aliasStr

# Commit virtual mailbox file
with open('/etc/postfix_conf/vmailbox', 'w+') as f:
    print >> f, vmail_str

# Update tbponly class with everyone in officers@
with open( '/etc/postfix_conf/restrict_classes/tbponly', 'w+' ) as f:
    for email in list( aliases[ 'officers@tbp.seas.ucla.edu' ] ) + officer_aliases:
        if email in copy_emails:
            continue

        print >>f, '%s\tOK' % ( email, )

# Update houseleaders class with everyone in *.leaders@
with open( '/etc/postfix_conf/restrict_classes/houseleaders', 'w+' ) as f:
    for alias, emails in aliases.iteritems():
        if re.match( r'^.*\.leaders.*$', alias ):
            for email in emails:
                print >>f, '%s\tOK' % ( email, )
