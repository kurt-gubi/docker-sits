# SITS 9.9.0 database on Oracle 12.2.0.1
```
docker build -t oracle:sits_990 .
```

Initialising an Oracle 12.2.0.1 database for SITS 9.9.0.

SITS files can be [downloaded from the MySITS website](https://www.mysits.com/).

Oracle metadata for SITS 9.9.0 can be extracted from the [SITS 9.9.0 STP](https://www.sitse-vision.co.uk/stp/index.html).

Method for extracting metadata from STP;
1. Extract database metadata with Oracle datapump export (ideally using `content=METADATA_ONLY`)
2. Convert the datapump file to SQL with Oracle datapump import (using the `sqlfile` and ideally `include` parameters)

Expected image available:
- oracle:12.2.0.1

Expected additional files;
- 990-REL01LID.zip
- 990-REL01ZIP.zip
- oracle-metadata/sits_metadata.FUNCTION.ALTER_FUNCTION.sql
- oracle-metadata/sits_metadata.FUNCTION.FUNCTION.sql
- oracle-metadata/sits_metadata.PACKAGE.COMPILE_PACKAGE.PACKAGE_SPEC.ALTER_PACKAGE_SPEC.sql
- oracle-metadata/sits_metadata.PACKAGE.PACKAGE_BODY.sql
- oracle-metadata/sits_metadata.PACKAGE.PACKAGE_SPEC.sql
- oracle-metadata/sits_metadata.PROCEDURE.ALTER_PROCEDURE.sql
- oracle-metadata/sits_metadata.PROCEDURE.PROCEDURE.sql
- oracle-metadata/sits_metadata.SEQUENCE.SEQUENCE.sql
- oracle-metadata/sits_metadata.TABLE.CONSTRAINT.CONSTRAINT.sql
- oracle-metadata/sits_metadata.TABLE.INDEX.INDEX.sql
- oracle-metadata/sits_metadata.TABLE.TABLE.sql
- oracle-metadata/sits_metadata.TABLE.TRIGGER.sql
- oracle-metadata/sits_metadata.TYPE.TYPE_SPEC.sql
- oracle-metadata/sits_metadata.VIEW.VIEW.sql
