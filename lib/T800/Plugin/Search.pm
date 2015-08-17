package T800::Plugin::Search;

use Moose;
use WWW::DuckDuckGo;

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::IRCHandler';


sub BUILD { shift->name('search') }

sub on_privmsg {
    my ($self, $who, $where, $what) = @_;
    return unless $what;

    my ($cmd, $params) = split ' ', $what, 2;
    if ($cmd eq $self->core->config->trigger . 'search') {
	
	my $channel = $where->[0];    
	my $zci = WWW::DuckDuckGo->new->zci($params);
	my $results = $zci->default_related_topics;
	
	print $params . "\n";
	use Data::Dumper;
	print Dumper $results;

	return unless defined($results);	
	my $result = shift @{ $results };
	my $message = $result->first_url . ' -- ' . $result->text;

	$self->irc->yield(privmsg => $channel => $message);
    }
}

__PACKAGE__->meta->make_immutable;
