package T800::Plugin::HTTPTitle;

use Moose;
use LWP;

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';

sub t800_init {
	my $self = shift;

	$self->name('httptitle');
}

sub on_privmsg {
	my ($self, $who, $where, $what ) = @_;
	my ($nick, $channel) = ((split '!', $who)[0],$where->[0]);

	my @message = (split / /, $what);
	foreach (@message) {
		if ($_ =~ /^http/) {
			my $title = '';
			my $ua = LWP::UserAgent->new;
			$ua->timeout(10);
			$ua->env_proxy;

			my $response = $ua->get($_);
			if ($response->is_success) {
				$title = $response->title();
			} else {
				$title = $response->status_line;
			}
			my $temp = 0;
			foreach ((split/\n/,$title)){
				$self->irc->yield(
					'privmsg',
					$channel,
					"$_"
				);
				$temp++;
				if ($temp == 3) {
					last;
				}
			}
		}
	}
}

__PACKAGE__->meta->make_immutable;
