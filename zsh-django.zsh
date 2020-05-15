alias dj='manage.py'
alias djcct='manage.py createcachetable'
alias djcme='manage.py compilemessages'
alias djcs='manage.py collectstatic'
alias djcsu='manage.py createsuperuser'
alias djfs='manage.py findstatic'
alias djdd='manage.py dumpdata'
alias djds='manage.py dbshell'
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
alias djt='manage.py test'
alias djts='manage.py testserver'

typeset -ga nul_args
nul_args=(
  "--verbosity=-[verbosity level; 0=minimal output, 1=normal output, 2=verbose output, 3=very verbose output.]:Verbosity:((0\:minimal 1\:normal 2\:verbose 3\:very-verbose))"
  "--settings=-[the Python path to a settings module.The Python path to a settings module, e.g. 'myproject.settings.main'. If this isn't provided, the DJANGO_SETTINGS_MODULE environment variable will be used.]:file:_files"
  "--pythonpath=-[a directory to add to the Python path.]:directory:_directories"
  "--traceback[print traceback on exception.]"
  "--no-color[Don't colorize the command output.]"
  "--force-color[Force colorization of the command output.]"
  "--version[show program's version number and exit.]"
  {-h,--help}'[show this help message and exit.]'
)

typeset -ga db_args
db_args=(
  '--database=-[Nominates a database. Defaults to the "default" database.]'
)

typeset -ga noinput_args
noinput_args=(
  '--noinput[Tells Django to NOT prompt the user for input of any kind.]'
)

_applabels() {
  local line
  local -a apps
  _call_program help-command \
    "./manage.py shell -c \\
        \"import sys; from django.apps import apps;\\
          [sys.stdout.write(app.label + '\n') for app in apps.get_app_configs()]\"" \
    | while read -A line; do apps=($line $apps) done
  _values 'Application' $apps && ret=0
}

_usernames() {
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

_appwithmigrations() {
  local -a apps

  for app in $(./manage.py showmigrations 2>&1 >/dev/null | awk '!/^[[:blank:]]/ {print}')
  do
    apps+=($app)
  done

  _values 'Apps' $apps && ret=0
}

_managepy-showmigrations() {
  _arguments -s : \
    '*::appname:_applabels' \
    '--list=-[Shows a list of all migrations and which are applied.]' \
    '--plan=-[Shows all migrations in the order they will be applied. With a verbosity level of 2 or above all direct migration dependencies and reverse dependencies (run_before) will be included.]' \
    $db_args \
    $nul_args && ret=0
}

_managepy-migrate() {
  _arguments -s : \
    '*::appname:_appwithmigrations' \
    '--fake=-[Mark migrations as run without actually running them.]' \
    '--fake-initial=-[Detect if tables already exist and fake-apply initial migrations if so. Make sure that the current database schema matches your initial migration before using this flag. Django will only check for an existing table name.]' \
    '--plan=-[Shows a list of the migration actions that will be performed.]' \
    '--run-syncdb=-[Creates tables for apps without migrations.]' \
    $db_args \
    $noinput_args \
    $nul_args && ret=0
}

_managepy-changepassword() {
  _arguments -s : \
    '*::username:_usernames' \
    $db_args \
    $nul_args && ret=0
}

_managepy-check() {
  _arguments -s : \
    '*::appname:_applabels' \
    '--tag=-[Run only checks labeled with given tag.]' \
    '--list-tags=-[List available tags.]' \
    '--deploy=-[Check deployment settings.]' \
    '--fail-level=-[Message level that will cause the command to exit with a non-zero status. Default is ERROR]:::(CRITICAL ERROR WARNING INFO DEBUG)' \
    $nul_args && ret=0
}

_managepy-shell() {
  _arguments -s : \
    '--no-startup=-[When using plain Python, ignore the PYTHONSTARTUP environment variable and ~/.pythonrc.py script.]' \
    '--interface=-[Specify an interactive interpreter interface. Available options: "ipython", "bpython", and "python"]:::(ipython bpython python)' \
    '--command=-[Instead of opening an interactive shell, run a command as Django and exit.]' \
    $nul_args && ret=0
}

_managepy-commands() {
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
    _managepy-commands
  else
    shift words
    (( CURRENT -- ))
    curcontext="${curcontext%:*:*}:managepy-$words[1]:"
    _call_function ret _managepy-$words[1]
  fi
}

compdef _managepy manage.py
