package WebService::CIA::Source::Web;

require 5.005_62;
use strict;
use warnings;
use LWP::UserAgent;
use Crypt::SSLeay;
use WebService::CIA::Parser;
use WebService::CIA::Source;

@WebService::CIA::Source::Web::ISA = ("WebService::CIA::Source");

our $VERSION = '0.01';

# Preloaded methods go here.

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};
    $self->{CACHED} = "";
    $self->{CACHE} = {};
    $self->{PARSER} = WebService::CIA::Parser->new;
    $self->{UA} = LWP::UserAgent->new;
	$self->{UA}->env_proxy(); # check for proxies
    bless ($self, $class);
    return $self;

}

sub value {

    my $self = shift;
    my ($cc, $f) = @_;

    unless ($self->cached eq $cc) {
        unless ($self->get($cc)) {
            return undef;
        }
    }

    if (exists $self->cache->{$f}) {
        return $self->cache->{$f};
    } else {
        return undef;
    }

}

sub all {

    my $self = shift;
    my $cc = shift;

    unless ($self->cached eq $cc) {
        unless ($self->get($cc)) {
            return {};
        }
    }

    return $self->cache;

}

sub get {

    my $self = shift;
    my $cc = shift;
    my $response = $self->ua->get("https://www.cia.gov/cia/publications/factbook/print/$cc.html");
    if ($response->is_success) {
        my $data = $self->parser->parse($cc, $response->content);
        $self->cache($data);
        $self->cached($cc);
        return 1;
    } else {
        return 0;
    }

}

sub ua {

    my $self = shift;
    return $self->{UA};

}

sub parser {

    my $self = shift;
    return $self->{PARSER};

}

sub cached {

    my $self = shift;
    if (@_) {
        $self->{CACHED} = shift;
    }
    return $self->{CACHED};

}

sub cache {

    my $self = shift;
    if (@_) {
        $self->{CACHE} = shift;
    }
    return $self->{CACHE};

}


1;

__END__


=head1 NAME

WebService::CIA::Source::Web - an interface to the online CIA World Factbook


=head1 SYNOPSIS

  use WebService::CIA::Source::Web;
  my $source = WebService::CIA::Source::DBM->new();


=head1 DESCRIPTION

WebService::CIA::Source::Web is an interface to the live, online version of the CIA
World Factbook.

It's a very slow way of doing things, but requires no pre-compiled DBM. It's
more likely to be useful for proving concepts or testing.


=head1 METHODS

Apart from C<new>, these methods are normally accessed via a WebService::CIA object.

=over 4

=item C<new()>

This method creates a new WebService::CIA::Source::Web object. It takes no arguments.

=item C<value($country_code, $field)>

Retrieve a value from the web.

C<$country_code> should be the FIPS 10-4 country code as defined in
L<https://www.cia.gov/cia/publications/factbook/appendix/appendix-d.html>.

C<$field> should be the name of the field whose value you want to
retrieve, as defined in
L<https://www.cia.gov/cia/publications/factbook/docs/notesanddefs.html>.
(WebService::CIA::Parser also creates four extra fields: "URL", "URL - Print",
"URL - Flag", and "URL - Map" which are the URLs of the country's Factbook
page, the printable version of that page, a GIF map of the country, and a
GIF flag of the country respectively.)

C<value> will return C<undef> if the country or field cannot be found, or if
there is an error GETing the page. This isn't ideal, but I can't think of the
best way around it right now.

=item C<all($country_code)>

Returns a hashref of field-value pairs for C<$country_code> or an empty
hashref if C<$country_code> isn't available from the Factbook.

=back

=head1 CACHING

In order to make some small improvement in efficiency, WebService::CIA::Source::Web
keeps a copy of the data for the last country downloaded in memory.


=head1 TO DO

=over 4

=item File system based caching of pages.

=item User-definable stack of cached countries, rather than just one.

=item Caching of last-modified headers; conditional GET.


=back

=head1 AUTHOR

Ian Malpass (ian@indecorous.com)


=head1 COPYRIGHT

Copyright 2003, Ian Malpass

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The CIA World Factbook's copyright information page
(L<https://www.cia.gov/cia/publications/factbook/docs/contributor_copyright.html>)
states:

  The Factbook is in the public domain. Accordingly, it may be copied
  freely without permission of the Central Intelligence Agency (CIA).


=head1 SEE ALSO

WebService::CIA, WebService::CIA::Parser, WebService::CIA::Source::DBM

=cut
