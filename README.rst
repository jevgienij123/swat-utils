swat-utils
%%%%%%%%%%

:Version:           1.0.0
:Home page:         https://github.com/sergeii/swat-utils
:Author:            Sergei Khoroshilov <kh.sergei@gmail.com>
:License:           The MIT License (http://opensource.org/licenses/MIT)

Description
===========
This package provides a collection of helper functions that operate upon UnrealScript native types such as string or array.

Installation
============

1. Download compiled binaries or compile the ``Utils`` package yourself.

   Every release is accompanied by two tar files, each containing a compiled package for a specific game version::

      swat-utils.X.Y.Z.swat4.tar.gz
      swat-utils.X.Y.Z.swat4exp.tar.gz

   with `X.Y.Z` being a package version, followed by a game version identifier::

      swat4 - SWAT 4 1.0-1.1
      swat4exp - SWAT 4: The Stetchkov Syndicate

   Please check the `releases page <https://github.com/sergeii/swat-utils/releases>`_ to get the latest stable package version appropriate to your server game version.

2. Copy contents of a tar archive into the server's ``System`` directory.

3. Open ``Swat4DedicatedServer.ini``

4. Navigate to the ``[Engine.GameEngine]`` section.

5. Insert the following line above any package line that makes a use of the library::

    ServerActors=Utils.Package

   For instance, if you had to install this package in order to satisfy the `HTTP <https://github.com/sergeii/swat-http>`_'s dependency requirements, you would insert the `ServerActors=Utils.Package` above the `ServerActors=HTTP.Package` line, otherwise the latter would fail to start up.

6. You have successfully installed the ``Utils`` package.