Linux
Prepare
Odoo needs a PostgreSQL server to run properly.

Debian/Ubuntu

The default configuration for the Odoo ‘deb’ package is to use the PostgreSQL server on the same host as the Odoo instance. Execute the following command to install the PostgreSQL server:

 sudo apt install postgresql -y
 Warning

wkhtmltopdf is not installed through pip and must be installed manually in version 0.12.6 for it to support headers and footers. Check out the wkhtmltopdf wiki for more details on the various versions.

Repository
Odoo S.A. provides a repository that can be used to install the Community edition by executing the following commands:

Debian/Ubuntu

 wget -q -O - https://nightly.odoo.com/odoo.key | sudo gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
 echo 'deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/19.0/nightly/deb/ ./' | sudo tee /etc/apt/sources.list.d/odoo.list
 sudo apt-get update && sudo apt-get install odoo
Use the usual apt-get upgrade command to keep the installation up-to-date.

 Note

Currently, there is no nightly repository for the Enterprise edition.

Distribution package
Instead of using the repository, packages for both the Community and Enterprise editions can be downloaded from the Odoo download page.

Debian/Ubuntu

 Note

Odoo 19 ‘deb’ package currently supports Debian Bookworm (12) and Ubuntu Jammy (22.04LTS) or above.

Once downloaded, execute the following commands as root to install Odoo as a service, create the necessary PostgreSQL user, and automatically start the server:

 dpkg -i <path_to_installation_package> # this probably fails with missing dependencies
 apt-get install -f # should install the missing dependencies
 dpkg -i <path_to_installation_package>
 Warning

The python3-xlwt Debian package, needed to export into the XLS format, does not exist in Debian Buster nor Ubuntu 18.04. If needed, install it manually with the following:

 sudo pip3 install xlwt
The num2words Python package - needed to render textual amounts - does not exist in Debian Buster nor Ubuntu 18.04, which could cause problems with the l10n_mx_edi module. If needed, install it manually with the following:

 sudo pip3 install num2words

