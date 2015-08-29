package T800::Plugin::LMGTFY;

use Moose;
use URI::Escape::XS qw(uri_escape);

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::IRCHandler';


sub BUILD { shift->name('lmgtfy') }

sub on_privmsg {
    my ($self, $who, $where, $what) = @_;
    return unless $what;

    my ($cmd, $params) = split ' ', $what, 2;
    if ($cmd eq $self->core->config->trigger . 'lmgtfy') {
	
	my $channel = $where->[0];
	
	print $params . "\n";
	my $message = "https://google.com/?q=" . uri_escape($params) ;

	$self->irc->yield(privmsg => $channel => $message);
    }
}

__PACKAGE__->meta->make_immutable;

