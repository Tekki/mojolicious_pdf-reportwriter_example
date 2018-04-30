package MojoRwr::Composer;
use Mojo::Base 'Mojolicious::Controller';
use Ragtime::ComposerList;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use PDF::ReportWriter;

sub list {
  my $self = shift;

  my $composers = Ragtime::ComposerList->load;
  $self->title('Mojolicious PDF::ReportWriter Example');
  $self->stash(subtitle => 'Ragtime Composers');
  $self->stash(list => $composers);

  $self->respond_to(
    html => {},
    pdf=> sub {
      my $base = catdir(dirname(__FILE__), '../../tmp');

      my $xmlfile = "$base/composers.xml";
      open my $out, '>', $xmlfile;
      print $out $self->render_to_string(format => 'rwr');
      close $out;

      my $rw = PDF::ReportWriter->new;
      my $data = $composers->to_arrayref;
      $rw->render_report($xmlfile, $data);
      unlink $xmlfile;

      $self->res->headers->content_disposition('attachment; filename=composers.pdf;');
      $self->render(data => $rw->stringify, format => 'pdf');
    },
  );

}

1;
