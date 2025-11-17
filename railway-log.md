Mounting volume on: /var/lib/containers/railwayapp/bind-mounts/509645a2-406f-4ef7-b183-1a3aaa8add71/vol_35sb48nn54bo90tu
2025-11-17 06:49:07,877 1 INFO ? odoo: Odoo version 18.0-20251106 
2025-11-17 06:49:07,877 1 INFO ? odoo: Using configuration file at /etc/odoo/odoo.conf 
2025-11-17 06:49:07,877 1 INFO ? odoo: addons paths: ['/usr/lib/python3/dist-packages/odoo/addons', '/mnt/extra-addons'] 
2025-11-17 06:49:07,877 1 INFO ? odoo: database: railway@postgres-7bcb294c.railway.internal:5432 
Warn: Can't find .pfb for face 'Courier'
2025-11-17 06:49:08,142 1 INFO ? odoo.addons.base.models.ir_actions_report: Will use the Wkhtmltopdf binary at /usr/local/bin/wkhtmltopdf 
2025-11-17 06:49:08,151 1 INFO ? odoo.addons.base.models.ir_actions_report: Will use the Wkhtmltoimage binary at /usr/local/bin/wkhtmltoimage 
2025-11-17 06:49:08,403 1 INFO ? odoo.service.server: HTTP service (werkzeug) running on 9e181c2989d7:8080 
2025-11-17 06:49:08,462 1 INFO railway odoo.modules.loading: loading 1 modules... 
2025-11-17 06:49:08,462 1 INFO railway odoo.modules.loading: Loading module base (1/1) 
2025-11-17 06:49:08,490 1 INFO railway odoo.modules.registry: module base: creating or updating database tables 
2025-11-17 06:49:08,668 1 ERROR ? odoo.http: Exception during request handling. 
    session = root.session_store.new()
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/odoo/tools/config.py", line 803, in session_dir
              ^^^^^^^^^^^^^^^^^^
    os.makedirs(d, 0o700)
  File "/usr/lib/python3/dist-packages/odoo/tools/func.py", line 42, in __get__
  File "<frozen os>", line 225, in makedirs
    value = self.fget(obj)
FileExistsError: [Errno 17] File exists: '/var/lib/odoo/sessions'
            ^^^^^^^^^^^^^^
During handling of the above exception, another exception occurred:
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2493, in session_store
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2568, in __call__
    request._post_init()
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 1654, in _post_init
    self.session, self.db = self._get_session_and_dbname()
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 1660, in _get_session_and_dbname
    path = odoo.tools.config.session_dir
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/tools/config.py", line 807, in session_dir
    assert os.access(d, os.W_OK), \
           ^^^^^^^^^^^^^^^^^^^^^
AssertionError: /var/lib/odoo/sessions: directory is not writable
2025-11-17 06:49:08,671 1 INFO ? werkzeug: 100.64.0.2 - - [17/Nov/2025 06:49:08] "GET /web/health HTTP/1.1" 500 - 0 0.000 0.006
    self.session, self.db = self._get_session_and_dbname()
2025-11-17 06:49:09,706 1 ERROR ? odoo.http: Exception during request handling. 
Traceback (most recent call last):
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/tools/config.py", line 803, in session_dir
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 1660, in _get_session_and_dbname
    os.makedirs(d, 0o700)
  File "<frozen os>", line 225, in makedirs
    session = root.session_store.new()
FileExistsError: [Errno 17] File exists: '/var/lib/odoo/sessions'
              ^^^^^^^^^^^^^^^^^^
During handling of the above exception, another exception occurred:
  File "/usr/lib/python3/dist-packages/odoo/tools/func.py", line 42, in __get__
    value = self.fget(obj)
Traceback (most recent call last):
            ^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2568, in __call__
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 2493, in session_store
    request._post_init()
  File "/usr/lib/python3/dist-packages/odoo/http.py", line 1654, in _post_init
    path = odoo.tools.config.session_dir
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/tools/config.py", line 807, in session_dir
    assert os.access(d, os.W_OK), \
           ^^^^^^^^^^^^^^^^^^^^^
AssertionError: /var/lib/odoo/sessions: directory is not writable
2025-11-17 06:49:09,707 1 INFO ? werkzeug: 100.64.0.2 - - [17/Nov/2025 06:49:09] "GET /web/health HTTP/1.1" 500 - 0 0.000 0.001
2025-11-17 06:49:09,798 1 INFO railway odoo.modules.loading: loading base/data/res_bank.xml 
2025-11-17 06:49:09,805 1 INFO railway odoo.modules.loading: loading base/data/res.lang.csv 
2025-11-17 06:49:10,170 1 INFO railway odoo.modules.loading: loading base/data/res_lang_data.xml 
2025-11-17 06:49:10,205 1 WARNING railway odoo.modules.loading: Transient module states were reset 
2025-11-17 06:49:10,205 1 ERROR railway odoo.modules.registry: Failed to load registry 
2025-11-17 06:49:10,205 1 CRITICAL railway odoo.service.server: Failed to initialize database `railway`. 
  File "/usr/lib/python3/dist-packages/odoo/models.py", line 5421, in _load_records_write
Traceback (most recent call last):
    self.write(values)
  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/res_lang.py", line 338, in write
  File "/usr/lib/python3/dist-packages/odoo/tools/convert.py", line 590, in _tag_root
    res = super(Lang, self).write(vals)
    f(rec)
  File "/usr/lib/python3/dist-packages/odoo/tools/convert.py", line 444, in _tag_record
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/models.py", line 4808, in write
    record = model._load_records([data], self.mode == 'update')
    field.write(self, value)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/fields.py", line 2725, in write
  File "/usr/lib/python3/dist-packages/odoo/models.py", line 5503, in _load_records
    super(Image, self).write(records, new_value)
    data['record']._load_records_write(data['values'])
  File "/usr/lib/python3/dist-packages/odoo/fields.py", line 2655, in write
    atts.write({'datas': value})
    open(full_path, 'ab').close()
    ^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/ir_attachment.py", line 603, in write
    return super(IrAttachment, self).write(vals)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/models.py", line 4840, in write
    fields[0].determine_inverse(real_recs)
  File "/usr/lib/python3/dist-packages/odoo/fields.py", line 1494, in determine_inverse
    determine(self.inverse, records)
  File "/usr/lib/python3/dist-packages/odoo/fields.py", line 110, in determine
    return needle(*args)
           ^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/ir_attachment.py", line 247, in _inverse_datas
    self._set_attachment_data(lambda attach: base64.b64decode(attach.datas or b''))
  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/ir_attachment.py", line 260, in _set_attachment_data
    self._file_delete(fname)
  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/ir_attachment.py", line 145, in _file_delete
    self._mark_for_gc(fname)
  File "/usr/lib/python3/dist-packages/odoo/addons/base/models/ir_attachment.py", line 158, in _mark_for_gc
PermissionError: [Errno 13] Permission denied: '/var/lib/odoo/filestore/railway/checklist/44/44d1661b24fa9f688091c8256535434b60aafba7'
                                        ^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/modules/loading.py", line 228, in load_module_graph
The above exception was the direct cause of the following exception:
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/odoo/service/server.py", line 1366, in preload_registries
    registry = Registry.new(dbname, update_module=update_module)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/decorator.py", line 232, in fun
    return caller(func, *(extras + args), **kw)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/tools/func.py", line 97, in locked
    return func(inst, *args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/odoo/modules/registry.py", line 129, in new
    odoo.modules.load_modules(registry, force_demo, status, update_module)
  File "/usr/lib/python3/dist-packages/odoo/modules/loading.py", line 431, in load_modules
    loaded_modules, processed_modules = load_module_graph(
    load_data(env, idref, mode, kind='data', package=package)