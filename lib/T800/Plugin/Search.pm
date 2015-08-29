package T800::Plugin::Search;

use Moose;
use REST::Google::Search qw(WEB);
use Data::Dumper;

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::IRCHandler';

with 'Universa::Role::Configuration' => {
    class      => 'T800::Plugin::Search::Config',
    configfile => 'search.yml',
};


sub BUILD { shift->name('search') }

sub on_privmsg {
	print "GOT PRIVMSG\n";
    my ($self, $who, $where, $what) = @_;
    return unless $what;
    my @requester = split('!', $who);
    my ($cmd, $params) = split ' ', $what, 2;
    if ($cmd eq $self->core->config->trigger . 'search') {


	my $channel = $where->[0];    
        REST::Google::Search->http_referer('http://9600-baud.net');
        my $res = REST::Google::Search->new(q => $params,);
	return warn "response status failure\n" if $res->responseStatus != 200;

	my $data = $res->responseData;
	my $result = shift $data->results;

        my $searchurl = $result->url;
        $self->irc->yield('privmsg', $channel, "$requester[0]: $searchurl is the first result."); 
    }
}

__PACKAGE__->meta->make_immutable;

package T800::Plugin::Seach::Config;

use Moose;
with 'MooseX::SimpleConfig';

has 'api_key' => ( isa => 'Str', is => 'ro', required => 1 );

__PACKAGE__->meta->make_immutable;

__DATA__
---
api_key: "INSERT KEY HERE"
...

