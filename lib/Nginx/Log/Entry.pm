package Nginx::Log::Entry;

use strict;
use warnings;
use Time::Piece;
use Nginx::ParseLog;

our $VERSION = 0.01;

=head1 NAME

Nginx::Log::Entry - This class represents a single line from the Nginx combined access log (the default access log format). It may work with the combined Apache log too, but I have not tested this.

=cut

=head1 SUBROUTINES/METHODS

=head2 new

Instantiates a new entry object.

=cut

sub new {
    my $class = shift;
    my $self = Nginx::ParseLog::parse(shift);
    return bless $self, $class;
}

=head2 get_ip

Returns the requestor's ip address.

=cut

sub get_ip {
    my $self = shift;
    return $self->{ip};
}

=head2 get_datetime_obj

Returns a L<Time::Piece> object of the request datetime.

=cut

sub get_datetime_obj {
    my $self = shift;
    unless (exists $self->{datetime_obj}) {
        my $date_string = substr($self->{time},0,-6);
        $self->{datetime_obj} = Time::Piece->strptime($date_string, "%d/%b/%Y:%H:%M:%S");
    }
    return $self->{datetime_obj};
}

=head2 get_timezone

Returns the timezone GMT modifier, e.g. -400.

=cut

sub get_timezone {
    my $self = shift;
    return substr($self->{time},-5);
}

=head2 was_robot

Returns 1 if the useragent string was a known robot, else returns 0.

=cut

sub was_robot {
    my $self = shift;
    my @bots = qw/YandexBot Googlebot bingbot Ezooms SurveyBot msnbot NetcraftSurveyAgent ScreenerBot FlightDeckReportsBot Baiduspider NetSeer 
        panscient.com survey Indy
        /;
    foreach my $bot (@bots) {
        return 1 if $self->{user_agent} =~ /$bot/i;
    }
    return 0;
}

=head2 get_status

Returns the http status number of the request.

=cut

sub get_status {
    my $self = shift;
    return $self->{status};
}

=head2 get_request

Returns the request string.

=cut

sub get_request {
    my $self = shift;
    return $self->{request};
}

=head2 get_request_type

Returns the http request type, e.g. GET.

=cut

sub get_request_type {
    my $self = shift;
    my @request = split(' ', $self->get_request);
    return $request[0];
}

=head2 get_request_url

Returns the requested url (excluding the base).

=cut

sub get_request_url {
    my $self = shift;
    my @request = split(' ', $self->get_request);
    return $request[1];
}

=head2 get_request_http_version

Returns http/1 or http/1.1.

=cut

sub get_request_http_version {
    my $self = shift;
    my @request = split(' ', $self->get_request);
    return $request[2];
}

=head2 was_request_successful

Returns 1 if the http status is a 200 series number (e.g. 200, 201, 202 etc), else returns 0.

=cut

sub was_request_successful {
    my $self = shift;
    my $status = $self->get_status;
    return substr($status,0,1) == 2 ? 1 : 0;
}

=head2 get_useragent

Returns the useragent string.

=cut

sub get_useragent {
    my $self = shift;
    return $self->{user_agent};
}

=head2 get_os

Returns the operating system, e.g. Windows.

=cut

sub get_os {
    my $self = shift;
    my %os = (  Android     => 'Android',
                Windows     => 'Windows',
                Macintosh   => 'OSX',
                Linux       => 'Linux',
                iPhone      => 'IOS',
                iPad        => 'IOS',
                Blackberry  => 'Blackberry',
                Symbian     => 'Symbian',
    );
    foreach my $system (keys %os) {
        return $os{$system} if $self->get_useragent =~ /$system/i; 
    }
    return 'Other';
}

=head2 get_browser

Returns the browser type, e.g. Firefox.

=cut

sub get_browser {
    my $self = shift;
    my %browsers = (    Internet_Explorer => 'msie',
                        Firefox           => 'firefox',
                        Chrome            => 'chrome',
                        Opera             => 'opera',
                        Safari            => 'safari',
                        Blackberry        => 'blackberry',
    );
    foreach my $browser (keys %browsers) {
        return $browser if $self->get_useragent =~ /$browsers{$browser}/i; 
    }
    return 'Other';
}

=head2 get_referer

Returns the referer, e.g. google.com.

=cut

sub get_referer {
    my $self = shift;
    return $self->{referer};
}

=head2 get_bytes

Returns the number of bytes sent, e.g. 754.

=cut

sub get_bytes {
    my $self = shift;
    return $self->{bytes_send};
}


=head2 get_remote_user

Returns the remote username. This is usually not set, and if not, returns '-' instead.

=cut

sub get_remote_user {
    my $self = shift;
    return $self->{remote_user};
}

1;
