package T800::Plugin::HTTPTitle;

use Moose;
use LWP;
use Data::Validate::URI qw(is_web_uri);

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
	my $urlcount = 0;
	foreach (@message) {
		if (is_web_uri($_)) {   #if ($_ =~ /^https?\:\/\/.+?\..+?/) {
                        $urlcount++;
			my $title = "";
			my $ua = LWP::UserAgent->new;
			$ua->timeout(10);
			$ua->env_proxy;

			my $response = $ua->get($_);
			if ($response->is_success) {
				$title = $response->title();
			        next unless defined $title;
				next if $title eq '';
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
				last if $temp == 3; 
			}
			last if $urlcount > 4;
		}
	}
}

__PACKAGE__->meta->make_immutable;
