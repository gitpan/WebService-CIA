package WebService::CIA::Parser;

require 5.005_62;
use strict;
use warnings;

our $VERSION = '0.01';

sub new {

    my $proto = shift;
    my $source = shift;
    my $class = ref($proto) || $proto;
    my $self = {};
    bless ($self, $class);
    return $self;

}
     

sub parse {

    my ($self, $cc, $html) = @_;

    my $data = {
        'URL - Flag'  => 'http://www.cia.gov/cia/publications/factbook/flags/' . $cc . '-flag.gif',
        'URL - Map'   => 'http://www.cia.gov/cia/publications/factbook/maps/'  . $cc . '-map.gif',
        'URL'         => 'http://www.cia.gov/cia/publications/factbook/geos/'  . $cc . '.html',
        'URL - Print' => 'http://www.cia.gov/cia/publications/factbook/geos/'  . $cc . '.html'
    };
    while ($html =~ m#
        <td[^>]+ class="FieldLabel">.*?
            <div.*?>
                (.+?):
            .*?</div>.*?
        </td>.*?
        <td[^>]+>
            (.*?)
        (</td>|</table>)
    #xsg) {
        my $field = $1;
        my $value = $2;
        $field =~ s/\s+/ /sg;
        $field =~ s/^\s*(.*?)\s*$/$1/;
        $value =~ s/\s+/ /sg;
        $value =~ s/^\s*(.*?)\s*$/$1/;
        $value =~ s/\s*<br>\s*/\n/g;
        $value =~ s/<\/?[^>+]>//g;
        $data->{$field} = $value;
    }

    return $data;

}



1;
__END__


=head1 NAME

WebService::CIA::Parser - Parse pages from the CIA World Factbook


=head1 SYNOPSIS

  use WebService::CIA::Parser;
  my $parser = WebService::CIA::Parser->new;
  my $data = $parser->parse($string);


=head1 DESCRIPTION

WebService::CIA::Parser takes a string of HTML and parses it. It will only give
sensible output if the string is the HTML for a page whose URL matches
C<http://www.cia.gov/cia/publications/factbook/print/[a-z]{2}\.html>

This parsing is somewhat fragile, since it assumes a certain page structure.
It'll work just as long as the CIA don't choose to alter their pages.


=head1 METHODS

=over 4

=item C<new>

Creates a new WebService::CIA::Parser object. It takes no arguments.

=item C<parse($html)>

Parses a string of HTML take from the CIA World Factbook. It takes a single
string as its argument and returns a hashref of fields and values.

The values are stripped of all HTML. C<E<lt>brE<gt>> tags are replaced by
newlines.

It also creates four extra fields: "URL", "URL - Print", "URL - Flag", and
"URL - Map" which are the URLs of the country's Factbook page, the
printable version of that page, a GIF map of the country, and a GIF flag
of the country respectively.


=back


=head1 EXAMPLE

  use WebService::CIA::Parser;
  use LWP::Simple qw(get);

  $html = get(
    "http://www.cia.gov/cia/publications/factbook/print/uk.html"
  );
  $parser = WebService::CIA::Parser->new;
  $data = $parser->parse($html);
  print $data->{"Population"};


=head1 AUTHOR

Ian Malpass (ian@indecorous.com)


=head1 COPYRIGHT

Copyright 2003, Ian Malpass

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The CIA World Factbook's copyright information page
(L<http://www.cia.gov/cia/publications/factbook/docs/contributor_copyright.html>)
states:

  The Factbook is in the public domain. Accordingly, it may be copied
  freely without permission of the Central Intelligence Agency (CIA).

=head1 SEE ALSO

WebService::CIA

=cut
