alias dj='manage.py'
alias djcct='manage.py createcachetable'
alias djcme='manage.py compilemessages'
alias djcs='manage.py collectstatic'
alias djcsu='manage.py createsuperuser'
alias djfs='manage.py findstatic'
alias djdd='manage.py dumpdata'
alias djdbs='manage.py dbshell'
alias djld='manage.py loaddata'
alias djm='manage.py migrate'
alias djmme='manage.py makemessages'
alias djmmi='manage.py makemigrations'
alias djrs='manage.py runserver'
alias djrf='manage.py runfcgi'
alias djs='manage.py shell'
alias djsa='manage.py startapp'
alias djsmi='manage.py showmigrations'
alias djsqmi='manage.py squashmigrations'
alias djsqlf='manage.py sqlflush'
alias djsqlm='manage.py sqlmigrate'
alias djsqlsr='manage.py sqlsequencereset'
alias djt='manage.py test'
alias djts='manage.py testserver'

typeset -ga nul_args
nul_args=(
  "(-v --verbosity)"{-v,--verbosity}"[verbosity level; 0=minimal output, 1=normal output, 2=verbose output, 3=very verbose output.]:verbosity:((0\:minimal 1\:normal 2\:verbose 3\:very-verbose))"
  "--settings=-[the Python path to a settings module.The Python path to a settings module, e.g. 'myproject.settings.main'. If this isn't provided, the DJANGO_SETTINGS_MODULE environment variable will be used.]:file:_files"
  "--pythonpath=-[a directory to add to the Python path.]:directory:_directories"
  "--traceback[print traceback on exception.]"
  "--no-color[Don't colorize the command output.]"
  "--force-color[Force colorization of the command output.]"
  "--version[show program's version number and exit.]"
  "(-h --help)"{-h,--help}"[show this help message and exit.]"
)

typeset -ga db_args
db_args=(
  '--database=-[Nominates a database. Defaults to the "default" database.]'
)

typeset -ga noinput_args
noinput_args=(
  '--noinput[Tells Django to NOT prompt the user for input of any kind.]'
)

_managepy_applabels() {
  local line
  local -a apps
  _call_program help-command \
    "./manage.py shell -c \\
        \"import sys; from django.apps import apps;\\
          [sys.stdout.write(app.label + '\n') for app in apps.get_app_configs()]\"" \
    | while read -A line; do apps=($line $apps) done
  _values 'Application' $apps && ret=0
}

_managepy_usernames() {
  local line
  local -a names
  _call_program help-command \
    "./manage.py shell -c \\
        \"import sys; from django.contrib.auth import get_user_model;\\
        User = get_user_model();\\
        [sys.stdout.write(username + '\n') for username in User.objects.values_list(User.USERNAME_FIELD, flat=True)]\"" \
    | while read -A line; do names=($line $names) done
  _values 'Usernames' $names && ret=0
}

_managepy_apps_with_migrations() {
  local -a apps

  for app in $(./manage.py showmigrations 2>&1 >/dev/null | awk '!/^ / {print}')
  do
    apps+=($app)
  done

  _values 'Apps' $apps && ret=0
}

_managepy_migrations() {
  local -a migrations
  migrations=('zero')
  for migration in $(./manage.py showmigrations 2>&1 >/dev/null | \
    awk -v drop=1 -v app=$words[2] '!/^ / {if ($0 == app) { drop=0 } else { drop=1 }} /^ / {if (!drop) {sub(/^ \[.\] /, ""); print}}')
  do
    migrations+=($migration)
  done
  _values 'Migrations' $migrations && ret=0
}

_managepy-changepassword() {
  _arguments -s : \
    '*::username:_managepy_usernames' \
    $db_args \
    $nul_args && ret=0
}

_managepy-check() {
  _arguments -s : \
    "*::appname:_managepy_applabels" \
    "--tag=-[Run only checks labeled with given tag.]" \
    "--list-tags[List available tags.]" \
    "--deploy[Check deployment settings.]" \
    "--fail-level=-[Message level that will cause the command to exit with a non-zero status. Default is ERROR]:level:(CRITICAL ERROR WARNING INFO DEBUG)" \
    $nul_args && ret=0
}

_managepy-collectstatic(){
  _arguments -s : \
    "--link[Create a symbolic link to each file instead of copying.]" \
    "--no-post-process[Do NOT post process collected files.]" \
    "--ignore=-[Ignore files or directories matching this glob-style pattern. Use multiple times to ignore more.]" \
    "--dry-run[Do everything except modify the filesystem.]" \
    "--clear[Clear the existing files using the storage before trying to copy or link the original file.]" \
    "--link[Create a symbolic link to each file instead of copying.]" \
    "--no-default-ignore[Do not ignore the common private glob-style patterns 'CVS', '.*' and '*~'.]" \
    $noinput_args \
    $nul_args && ret=0
}

_managepy-compilemessages(){
  _arguments -s : \
    {-l,--locale=}"[Locale(s) to process (e.g. de_AT). Default is to process all. Can be used multiple times.]" \
    {-x,--exclude=}"[Locales to exclude. Default is none. Can be used multiple times.]" \
    {-f,--use-fuzzy}"[Use fuzzy translations.]" \
    $nul_args && ret=0
}

_managepy-createcachetable(){
  _arguments -s : \
    "--dry-run[Does not create the table, just prints the SQL that would be run.]" \
    $db_args \
    $nul_args && ret=0
}

_managepy-createsuperuser(){
  _arguments -s : \
    "--username=-[Specifies the login for the superuser.]" \
    $db_args \
    $noinput_args \
    $nul_args && ret=0
}

_managepy-dbshell(){
  _arguments -s : \
    $db_args \
    $nul_args && ret=0
}

_managepy-diffsettings(){
  _arguments -s : \
    "--all[Display all settings, regardless of their value.]" \
    "--default=-[The settings module to compare the current settings against. Leave empty to compare against Django's default settings.]" \
    "--output=-[Selects the output format. 'hash' mode displays each changed setting, with the settings that don't appear in the defaults followed by ###. 'unified' mode prefixes the default setting with a minus sign, followed by the changed setting prefixed with a plus sign.]:::(hash unified)" \
    $nul_args && ret=0
}

_managepy-dumpdata(){
  _arguments -s : \
    "*::appname:_managepy_applabels" \
    "--format=-[Specifies the output serialization format for fixtures.]:format:(json yaml xml)" \
    "--indent=-[Specifies the indent level to use when pretty-printing output.]" \
    {-e,--exclude=}"[An app_label or app_label.ModelName to exclude (use multiple --exclude to exclude multiple apps/models).]" \
    "--natural-foreign[Use natural foreign keys if they are available.]" \
    "--natural-primary[Use natural primary keys if they are available.]" \
    "(-a --all)"{-a,--all}"[Use Django's base manager to dump all models stored in the database.]" \
    "--pks=-[Only dump objects with given primary keys.]" \
    "(-o --output)"{-o,--output=}"[Specifies file to which the output is written.]"
    $db_args \
    $nul_args && ret=0
}

_managepy-findstatic() {
  _arguments -s : \
    "--first[Only return the first match for each static file.]" \
    $nul_args && ret=0
}

_managepy-flush(){
  _arguments -s : \
    $db_args \
    $nul_args && ret=0
}

_managepy-help(){
  _arguments -s : \
    "*:command:_managepy_commands" \
    $nul_args && ret=0
}

_managepy-inspectdb(){
  _arguments -s : \
    "--include-partitions[Also output models for partition tables.]" \
    "--include-views[Also output models for database views.]" \
    $db_args \
    $nul_args && ret=0
}

_managepy-loaddata(){
  _arguments -s : \
    "--app=-[Only look for fixtures in the specified app.]:appname:_managepy_applabels" \
    "(-i --ignorenonexistent)"{-i,--ignorenonexistent}"[Ignores entries in the serialized data for fields that do not currently exist on the model.]" \
    {-e,--exclude=}"[An app_label or app_label.ModelName to exclude. Can be used multiple times.]" \
    "--format=-[An app_label or app_label.ModelName to exclude. Can be used multiple times.]" \
    "*::file:_files" \
    $db_args \
    $nul_args && ret=0
}

_managepy-makemessages(){
  _arguments -s : \
    {-l,--locale=}"[Creates or updates the message files for the given locale(s) (e.g. pt_BR).]" \
    "(-d --domain)"{-d,--domain=}"[The domain of the message files (default: 'django').]" \
    "(-a --all)"{-a,--all}"[Updates the message files for all existing locales.]" \
    {-e,--extension=}"[The file extension(s) to examine (default: 'html,txt', or 'js' if the domain is 'djangojs').]" \
    "(-s --symlinks)"{-s,--symlinks}"[Follows symlinks to directories when examining source code and templates for translation strings.]" \
    {-i,--ignore=}"[Ignore files or directories matching this glob-style pattern.]" \
    "--no-default-ignore[Don't ignore the common glob-style patterns 'CVS', '.*', '*~' and '*.pyc'.]" \
    "--no-wrap[Don't break long message lines into several lines.]" \
    "--no-location[Don't write '#: filename:line' lines.]" \
    "--no-obsolete[Remove obsolete message strings.]" \
    "--keep-pot[Keep .pot file after making messages.]" \
    "--add-location=-[Controls '#: filename:line' lines. If the option is 'full' (the default if not given), the lines include both file name and line number. If it's 'file', the line number is omitted. If it's 'never', the lines are suppressed (same as --no-location). --add-location requires gettext 0.19 or newer.]:::(full file never)" \
    $nul_args && ret=0
}

_managepy-makemigrations(){
  _arguments -s : \
    "*::appname:_managepy_applabels" \
    "--dry-run[Just show what migrations would be made]" \
    "--merge[Enable fixing of migration conflicts.]" \
    "--empty[Create an empty migration.]" \
    "--check[Exit with a non-zero status if model changes are missing migrations.]" \
    "--no-header[Do not add header comments to new migration file(s).]" \
    "(-n --name)"{-n,--name=}"[Use this name for migration file(s).]" \
    $noinput_args \
    $nul_args && ret=0
}

_managepy-migrate() {
  _arguments -s : \
    "1::appname:_managepy_apps_with_migrations" \
    "2::migration:_managepy_migrations" \
    "--fake[Mark migrations as run without actually running them.]" \
    "--fake-initial[Detect if tables already exist and fake-apply initial migrations if so. Make sure that the current database schema matches your initial migration before using this flag. Django will only check for an existing table name.]" \
    "--plan[Shows a list of the migration actions that will be performed.]" \
    "--run-syncdb[Creates tables for apps without migrations.]" \
    $db_args \
    $noinput_args \
    $nul_args && ret=0
}

_managepy-runserver(){
  _arguments -s : \
    "(-6 --ipv6)"{-6,--ipv6}"[Tells Django to use an IPv6 address.]" \
    "--nothreading[Tells Django to NOT use threading.]" \
    "--noreload[Tells Django to NOT use the auto-reloader.]" \
    "--nostatic[Tells Django to NOT automatically serve static files at STATIC_URL.]" \
    "--insecure[Allows serving static files even if DEBUG is False.]" \
    $nul_args && ret=0
}

_managepy-sendtestemail() {
  _arguments -s : \
    "--managers[Send a test email to the addresses specified in settings.MANAGERS.]" \
    "--admins[Send a test email to the addresses specified in settings.ADMINS.]" \
    $nul_args && ret=0
}

_managepy-shell() {
  _arguments -s : \
    "--no-startup=-[When using plain Python, ignore the PYTHONSTARTUP environment variable and ~/.pythonrc.py script.]" \
    "(-i --interface)"{-i,--interface=}"[Specify an interactive interpreter interface. Available options: 'ipython', 'bpython', and 'python']:::(ipython bpython python)" \
    "--command=-[Instead of opening an interactive shell, run a command as Django and exit.]" \
    $nul_args && ret=0
}

_managepy-showmigrations() {
  _arguments -s : \
    "*::appname:_managepy_applabels" \
    "(-l --list)"{-l,--list}"[Shows a list of all migrations and which are applied.]" \
    "(-p --plan)"{-p,--plan}"[Shows all migrations in the order they will be applied. With a verbosity level of 2 or above all direct migration dependencies and reverse dependencies (run_before) will be included.]" \
    $db_args \
    $nul_args && ret=0
}

_managepy-sqlflush(){
  _arguments -s : \
    $db_args \
    $nul_args && ret=0
}

_managepy-sqlmigrate(){
  _arguments -s : \
    "1::appname:_managepy_apps_with_migrations" \
    "2::migration:_managepy_migrations" \
    "--backwards[Create SQL to unapply the migration, rather than to apply it.]" \
    $db_args \
    $nul_args && ret=0
}

_managepy-sqlsequencereset(){
  _arguments -s : \
    "*::appname:_managepy_applabels" \
    $db_args \
    $nul_args && ret=0
}

_managepy-squashmigrations(){
  _arguments -s : \
    "1::appname:_managepy_apps_with_migrations" \
    "--no-optimize[Do not try to optimize the squashed operations.]" \
    "--no-header[Do not add a header comment to the new squashed migration.]" \
    "--squashed-name=-[Sets the name of the new squashed migration.]" \
    $noinput_args \
    $nul_args && ret=0
}

_managepy-startapp(){
  _arguments -s : \
    "--template=-[The path or URL to load the template from.]:directory:_directories" \
    {-e,--extension}"=-[The file extension(s) to render (default: 'py'). Separate multiple extensions with commas, or use -e multiple times.]" \
    "(-n --name)"{-n,--name}"=-[The file name(s) to render.]:file:_files"
    $nul_args && ret=0
}

_managepy-test() {
  _arguments -s : \
    "--failfast[Tells Django to stop running the test suite after first failed test.]" \
    "--testrunner=-[Tells Django to use specified test runner class instead of the one specified by the TEST_RUNNER setting.]" \
    "--liveserver=-[Overrides the default address where the live server (used with LiveServerTestCase) is expected to run from. The default value is localhost:8081.]" \
    "(-t --top-level-directory)"{-t,--top-level-directory}"=-[Top level of project for unittest discovery.]" \
    "(-p --pattern)"{-p,--pattern}"=-[The test matching pattern. Defaults to test*.py.]:" \
    "(-k --keepdb)"{-k,--keebdb}"[Preserves the test DB between runs.]" \
    "(-r --reverse)"{-r,--reverse}"[Reverses test cases order.]" \
    "--debug-mode[Sets settings.DEBUG to True.]" \
    "(-d --debug-sql)"{-d,--debug-sql}"[Prints logged SQL queries on failure.]" \
    "--parallel[Run tests using up to N parallel processes.]:int" \
    "--tag=-[Run only tests with the specified tag. Can be used multiple times.]" \
    "--exclude-tag=[Do not run tests with the specified tag. Can be used multiple times.]" \
    $noinput_args \
    $nul_args && ret=0
}

_managepy-testserver(){
  _arguments -s : \
    "(-6 --ipv6)"{-6,--ipv6}"[Tells Django to use an IPv6 address.]" \
    "--addrport=-[Port number or ipaddr:port to run the server on.]" \
    '*::file:_files' \
    $noinput_args \
    $nul_args && ret=0
}

_managepy_commands() {
  local -a commands

  for cmd in $(./manage.py --help 2>&1 >/dev/null | \
               awk -v drop=1 '{ if (!drop && $0 && substr($0,1,1) !~ /\[/) {sub(/^[ \t]+/, ""); print} } /^Available subcommands/ { drop=0 }')
  do
    commands+=($cmd)
  done

  _describe -t commands 'manage.py command' commands && ret=0
}

_managepy() {
  local curcontext=$curcontext ret=1

  if ((CURRENT == 2)); then
    _managepy_commands
  else
    shift words
    (( CURRENT -- ))
    curcontext="${curcontext%:*:*}:managepy-$words[1]:"
    _call_function ret _managepy-$words[1]
  fi
}

compdef _managepy manage.py
