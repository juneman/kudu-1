# Copyright (c) 2014, Cloudera, inc.
# Confidential Cloudera Information: Covered by NDA.

# distutils: language = c++

from libc.stdint cimport *
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

# This must be included for cerr and other things to work
cdef extern from "<iostream>":
    pass

#----------------------------------------------------------------------
# Smart pointers and such

cdef extern from "<tr1/memory>" namespace "std::tr1" nogil:

    cdef cppclass shared_ptr[T]:
        T* get()
        void reset()
        void reset(T* p)

cdef extern from "kudu/gutil/gscoped_ptr.h" nogil:

    cdef cppclass gscoped_ptr[T]:
        T* get()
        T& operator*()
        void reset(T* p)
        gscoped_ptr[T] Pass()

cdef extern from "kudu/gutil/ref_counted.h" nogil:

    cdef cppclass scoped_refptr[T]:
        T* get()
        T& operator*()
        void reset(T* p)

cdef extern from "kudu/util/status.h" namespace "kudu" nogil:

    # We can later add more of the common status factory methods as needed
    cdef Status Status_OK "Status::OK"()

    cdef cppclass Status:
        Status()

        string ToString()

        bool ok()
        bool IsNotFound()
        bool IsCorruption()
        bool IsNotSupported()
        bool IsIOError()
        bool IsInvalidArgument()
        bool IsAlreadyPresent()
        bool IsRuntimeError()
        bool IsNetworkError()
        bool IsIllegalState()
        bool IsNotAuthorized()
        bool IsAborted()


cdef extern from "kudu/util/monotime.h" namespace "kudu" nogil:

    # These classes are not yet needed directly but will need to be completed
    # from the C++ API
    cdef cppclass MonoDelta:
        pass

    cdef cppclass MonoTime:
        pass


cdef extern from "kudu/client/schema.h" namespace "kudu::client" nogil:

    enum DataType" kudu::client::KuduColumnSchema::DataType":
        KUDU_UINT8 " kudu::client::KuduColumnSchema::UINT8"
        KUDU_INT8 " kudu::client::KuduColumnSchema::INT8"
        KUDU_UINT16 " kudu::client::KuduColumnSchema::UINT16"
        KUDU_INT16 " kudu::client::KuduColumnSchema::INT16"
        KUDU_UINT32 " kudu::client::KuduColumnSchema::UINT32"
        KUDU_INT32 " kudu::client::KuduColumnSchema::INT32"
        KUDU_UINT64 " kudu::client::KuduColumnSchema::UINT64"
        KUDU_INT64 " kudu::client::KuduColumnSchema::INT64"
        KUDU_STRING " kudu::client::KuduColumnSchema::STRING"
        KUDU_BOOL " kudu::client::KuduColumnSchema::BOOL"
        KUDU_FLOAT " kudu::client::KuduColumnSchema::FLOAT"
        KUDU_DOUBLE " kudu::client::KuduColumnSchema::DOUBLE"

    enum EncodingType" kudu::client::KuduColumnStorageAttributes::EncodingType":
        ENCODING_AUTO " kudu::client::KuduColumnStorageAttributes::AUTO_ENCODING"
        ENCODING_PLAIN " kudu::client::KuduColumnStorageAttributes::PLAIN_ENCODING"
        ENCODING_PREFIX " kudu::client::KuduColumnStorageAttributes::PREFIX_ENCODING"
        ENCODING_GROUP_VARINT " kudu::client::KuduColumnStorageAttributes::GROUP_VARINT"
        ENCODING_RLE " kudu::client::KuduColumnStorageAttributes::RLE"

    enum CompressionType" kudu::client::KuduColumnStorageAttributes::CompressionType":
        COMPRESSION_DEFAULT " kudu::client::KuduColumnStorageAttributes::DEFAULT_COMPRESSION"
        COMPRESSION_NONE " kudu::client::KuduColumnStorageAttributes::NO_COMPRESSION"
        COMPRESSION_SNAPPY " kudu::client::KuduColumnStorageAttributes::SNAPPY"
        COMPRESSION_LZ4 " kudu::client::KuduColumnStorageAttributes::LZ4"
        COMPRESSION_ZLIB " kudu::client::KuduColumnStorageAttributes::ZLIB"

    cdef cppclass KuduColumnStorageAttributes:
        KuduColumnStorageAttributes()
        KuduColumnStorageAttributes(EncodingType encoding)
        KuduColumnStorageAttributes(EncodingType encoding,
                                    CompressionType compression)

        EncodingType encoding()
        CompressionType compression()
        string ToString()

    cdef cppclass KuduColumnSchema:
        KuduColumnSchema(KuduColumnSchema& other)
        KuduColumnSchema(string& name, DataType type)
        KuduColumnSchema(string& name, DataType type, bool is_nullable)
        KuduColumnSchema(string& name, DataType type, bool is_nullable,
                         const void* default_value)

        string& name()
        bool is_nullable()
        DataType type()

        bool Equals(KuduColumnSchema& other)
        void CopyFrom(KuduColumnSchema& other)

    cdef cppclass KuduSchema:
        KuduSchema()
        KuduSchema(vector[KuduColumnSchema]& columns, int key_columns)

        void Reset(vector[KuduColumnSchema]& columns, int key_columns)

        bool Equals(KuduSchema& other)
        KuduColumnSchema Column(size_t idx)
        KuduSchema CreateKeyProjection()
        size_t num_columns()


cdef extern from "kudu/client/row_result.h" namespace "kudu::client" nogil:

    cdef cppclass KuduRowResult:
        bool IsNull(Slice& col_name)
        bool IsNull(int col_idx)

        # These getters return a bad Status if the type does not match,
        # the value is unset, or the value is NULL. Otherwise they return
        # the current set value in *val.
        Status GetBool(Slice& col_name, bool* val)

        Status GetInt8(Slice& col_name, int8_t* val)
        Status GetInt16(Slice& col_name, int16_t* val)
        Status GetInt32(Slice& col_name, int32_t* val)
        Status GetInt64(Slice& col_name, int64_t* val)

        Status GetUInt8(Slice& col_name, uint8_t* val)
        Status GetUInt16(Slice& col_name, uint16_t* val)
        Status GetUInt32(Slice& col_name, uint32_t* val)
        Status GetUInt64(Slice& col_name, uint64_t* val)

        Status GetBool(int col_idx, bool* val)

        Status GetInt8(int col_idx, int8_t* val)
        Status GetInt16(int col_idx, int16_t* val)
        Status GetInt32(int col_idx, int32_t* val)
        Status GetInt64(int col_idx, int64_t* val)

        Status GetUInt8(int col_idx, uint8_t* val)
        Status GetUInt16(int col_idx, uint16_t* val)
        Status GetUInt32(int col_idx, uint32_t* val)
        Status GetUInt64(int col_idx, uint64_t* val)

        Status GetString(Slice& col_name, Slice* val)
        Status GetString(int col_idx, Slice* val)

        Status GetFloat(Slice& col_name, float* val)
        Status GetFloat(int col_idx, float* val)

        Status GetDouble(Slice& col_name, double* val)
        Status GetDouble(int col_idx, double* val)

        const void* cell(int col_idx)
        string ToString()


cdef extern from "kudu/util/slice.h" namespace "kudu" nogil:

    cdef cppclass Slice:
        Slice()
        Slice(const uint8_t* data, size_t n)
        Slice(const char* data, size_t n)

        Slice(string& s)
        Slice(const char* s)

        # Many other constructors have been omitted; we can return and add them
        # as needed for the code generation.

        const uint8_t* data()
        uint8_t* mutable_data()
        size_t size()
        bool empty()

        uint8_t operator[](size_t n)

        void clear()
        void remove_prefix(size_t n)
        void truncate(size_t n)

        Status check_size(size_t expected_size)

        string ToString()

        string ToDebugString()
        string ToDebugString(size_t max_len)

        int compare(Slice& b)

        bool starts_with(Slice& x)

        void relocate(uint8_t* d)

        # Many other API methods omitted


cdef extern from "kudu/common/partial_row.h" namespace "kudu" nogil:

    cdef cppclass KuduPartialRow:
        # Schema must not be garbage-collected
        # KuduPartialRow(const Schema* schema)

        #----------------------------------------------------------------------
        # Setters

        # Slice setters
        Status SetBool(Slice& col_name, bool val)

        Status SetInt8(Slice& col_name, int8_t val)
        Status SetInt16(Slice& col_name, int16_t val)
        Status SetInt32(Slice& col_name, int32_t val)
        Status SetInt64(Slice& col_name, int64_t val)

        Status SetUInt8(Slice& col_name, uint8_t val)
        Status SetUInt16(Slice& col_name, uint16_t val)
        Status SetUInt32(Slice& col_name, uint32_t val)
        Status SetUInt64(Slice& col_name, uint64_t val)

        Status SetDouble(Slice& col_name, double val)
        Status SetFloat(Slice& col_name, float val)

        # Integer setters
        Status SetBool(int col_idx, bool val)

        Status SetInt8(int col_idx, int8_t val)
        Status SetInt16(int col_idx, int16_t val)
        Status SetInt32(int col_idx, int32_t val)
        Status SetInt64(int col_idx, int64_t val)

        Status SetUInt8(int col_idx, uint8_t val)
        Status SetUInt16(int col_idx, uint16_t val)
        Status SetUInt32(int col_idx, uint32_t val)
        Status SetUInt64(int col_idx, uint64_t val)

        Status SetDouble(int col_idx, double val)
        Status SetFloat(int col_idx, float val)

        # Set, but does not copy string
        Status SetString(Slice& col_name, Slice& val)
        Status SetString(int col_idx, Slice& val)

        Status SetStringCopy(Slice& col_name, Slice& val)
        Status SetStringCopy(int col_idx, Slice& val)

        Status SetNull(Slice& col_name)
        Status SetNull(int col_idx)

        Status Unset(Slice& col_name)
        Status Unset(int col_idx)

        #----------------------------------------------------------------------
        # Getters

        bool IsColumnSet(Slice& col_name)
        bool IsColumnSet(int col_idx)

        bool IsNull(Slice& col_name)
        bool IsNull(int col_idx)

        Status GetBool(Slice& col_name, bool* val)

        Status GetInt8(Slice& col_name, int8_t* val)
        Status GetInt16(Slice& col_name, int16_t* val)
        Status GetInt32(Slice& col_name, int32_t* val)
        Status GetInt64(Slice& col_name, int64_t* val)

        Status GetUInt8(Slice& col_name, uint8_t* val)
        Status GetUInt16(Slice& col_name, uint16_t* val)
        Status GetUInt32(Slice& col_name, uint32_t* val)
        Status GetUInt64(Slice& col_name, uint64_t* val)

        Status GetDouble(Slice& col_name, double* val)
        Status GetFloat(Slice& col_name, float* val)

        Status GetBool(int col_idx, bool* val)

        Status GetInt8(int col_idx, int8_t* val)
        Status GetInt16(int col_idx, int16_t* val)
        Status GetInt32(int col_idx, int32_t* val)
        Status GetInt64(int col_idx, int64_t* val)

        Status GetUInt8(int col_idx, uint8_t* val)
        Status GetUInt16(int col_idx, uint16_t* val)
        Status GetUInt32(int col_idx, uint32_t* val)
        Status GetUInt64(int col_idx, uint64_t* val)

        Status GetDouble(int col_idx, double* val)
        Status GetFloat(int col_idx, float* val)

        # Gets the string but does not copy the value. Callers should
        # copy the resulting Slice if necessary.
        Status GetString(Slice& col_name, Slice* val)
        Status GetString(int col_idx, Slice* val)

        # Return true if all of the key columns have been specified
        # for this mutation.
        bool IsKeySet()

        # Return true if all columns have been specified.
        bool AllColumnsSet()
        string ToString()

        # This relied on a forward declaration of Schema, but we don't want to
        # include the header file here at the moment.

        # Schema* schema()


cdef extern from "kudu/client/write_op.h" namespace "kudu::client" nogil:

    enum WriteType" kudu::client::KuduWriteOperation::Type":
        INSERT " kudu::client::KuduWriteOperation::INSERT"
        UPDATE " kudu::client::KuduWriteOperation::UPDATE"
        DELETE " kudu::client::KuduWriteOperation::DELETE"

    cdef cppclass KuduWriteOperation:
        KuduPartialRow& row()
        KuduPartialRow* mutable_row()

        # This is a pure virtual function implemented on each of the cppclass
        # subclasses
        string ToString()

        # Also a pure virtual
        WriteType type()

    cdef cppclass KuduInsert(KuduWriteOperation):
        pass

    cdef cppclass KuduDelete(KuduWriteOperation):
        pass

    cdef cppclass KuduUpdate(KuduWriteOperation):
        pass


cdef extern from "kudu/client/scan_predicate.h" namespace "kudu::client" nogil:

    cdef cppclass KuduColumnRangePredicate:
        KuduColumnRangePredicate(KuduColumnSchema& col,
                                 const void* lower_bound,
                                 const void* upper_bound)
        void CopyFrom(KuduColumnRangePredicate& other)


cdef extern from "kudu/gutil/callback.h" namespace "kudu" nogil:

    # Have not yet attempted to implement callbacks
    cdef cppclass Callback[T]:
        pass

    # const-ness may be a problem here
    # kudu/util/status_callback.h
    # typedef Callback<void(const Status& status)> StatusCallback
    ctypedef Callback[void(Status& status)] StatusCallback

cdef extern from "kudu/client/client.h" namespace "kudu::client" nogil:

    # Omitted KuduClient::ReplicaSelection enum

    cdef cppclass KuduClient:

        Status DeleteTable(string& table_name)
        Status OpenTable(string& table_name, scoped_refptr[KuduTable]* table)
        Status GetTableSchema(string& table_name, KuduSchema* schema)

        gscoped_ptr[KuduTableCreator] NewTableCreator()
        Status IsCreateTableInProgress(string& table_name,
                                       bool* create_in_progress)

        gscoped_ptr[KuduTableAlterer] NewTableAlterer()
        Status IsAlterTableInProgress(string& table_name,
                                      bool* alter_in_progress)

        shared_ptr[KuduSession] NewSession()

        vector[string]& master_server_addrs()

    cdef cppclass KuduClientBuilder:
        KuduClientBuilder()
        KuduClientBuilder& master_server_addrs(vector[string]& addrs)
        KuduClientBuilder& master_server_addr(string& addr)

        Status Build(shared_ptr[KuduClient]* client)

    cdef cppclass KuduTableCreator:
        KuduTableCreator& table_name(string& name)
        KuduTableCreator& schema(KuduSchema* name)
        KuduTableCreator& split_keys(vector[string]& keys)
        KuduTableCreator& num_replicas(int n_replicas)
        KuduTableCreator& wait(bool wait)

        Status Create()

    cdef cppclass KuduTableAlterer:
        # The name of the existing table to alter
        KuduTableAlterer& table_name(string& name)

        KuduTableAlterer& rename_table(string& name)

        KuduTableAlterer& add_column(string& name, DataType type,
                                     const void *default_value)
        KuduTableAlterer& add_column(string& name, DataType type,
                                     const void *default_value,
                                     KuduColumnStorageAttributes attr)

        KuduTableAlterer& add_nullable_column(string& name, DataType type)

        KuduTableAlterer& drop_column(string& name)

        KuduTableAlterer& rename_column(string& old_name, string& new_name)

        KuduTableAlterer& wait(bool wait)

        Status Alter()

    # Instances of KuduTable are not directly instantiated by users of the
    # client.
    cdef cppclass KuduTable:

        string& name()
        KuduSchema& schema()

        gscoped_ptr[KuduInsert] NewInsert()
        gscoped_ptr[KuduUpdate] NewUpdate()
        gscoped_ptr[KuduDelete] NewDelete()

        KuduClient* client()

    enum FlushMode" kudu::client::KuduSession::FlushMode":
        AUTO_FLUSH_SYNC " kudu::client::KuduSession::AUTO_FLUSH_SYNC"
        AUTO_FLUSH_BACKGROUND " kudu::client::KuduSession::AUTO_FLUSH_BACKGROUND"
        MANUAL_FLUSH " kudu::client::KuduSession::MANUAL_FLUSH"

    cdef cppclass KuduSession:

        Status SetFlushMode(FlushMode m)

        void SetMutationBufferSpace(size_t size)
        void SetTimeoutMillis(int millis)

        void SetPriority(int priority)

        Status Apply(gscoped_ptr[KuduWriteOperation] write_op)
        Status Apply(gscoped_ptr[KuduInsert] write_op)
        Status Apply(gscoped_ptr[KuduUpdate] write_op)
        Status Apply(gscoped_ptr[KuduDelete] write_op)

        # This is thread-safe
        Status Flush()

        # TODO: Will need to decide on a strategy for exposing the session's
        # async API to Python

        # Status ApplyAsync(gscoped_ptr[KuduWriteOperation] write_op,
        #                   StatusCallback cb)
        # Status ApplyAsync(gscoped_ptr[KuduInsert] write_op,
        #                   StatusCallback cb)
        # Status ApplyAsync(gscoped_ptr[KuduUpdate] write_op,
        #                   StatusCallback cb)
        # Status ApplyAsync(gscoped_ptr[KuduDelete] write_op,
        #                   StatusCallback cb)
        # void FlushAsync(StatusCallback& cb)


        Status Close()
        bool HasPendingOperations()
        int CountBufferedOperations()

        int CountPendingErrors()
        void GetPendingErrors(vector[C_KuduError*]* errors, bool* overflowed)

        KuduClient* client()

    enum ReadMode" kudu::client::KuduScanner::ReadMode":
        READ_LATEST " kudu::client::KuduScanner::READ_LATEST"
        READ_AT_SNAPSHOT " kudu::client::KuduScanner::READ_AT_SNAPSHOT"

    cdef cppclass KuduScanner:
        KuduScanner(KuduTable* table)

        Status SetProjection(KuduSchema* projection)
        Status AddConjunctPredicate(KuduColumnRangePredicate& pred)

        Status Open()
        void Close()

        bool HasMoreRows()
        Status NextBatch(vector[KuduRowResult]* rows)
        Status SetBatchSizeBytes(uint32_t batch_size)

        # Pending definition of ReplicaSelection enum
        # Status SetSelection(ReplicaSelection selection)

        Status SetReadMode(ReadMode read_mode)
        Status SetSnapshot(uint64_t snapshot_timestamp_micros)
        Status SetTimeoutMillis(int millis)

        string ToString()

    cdef cppclass C_KuduError " kudu::client::KuduError":

        Status& status()

        KuduWriteOperation& failed_op()
        gscoped_ptr[KuduWriteOperation] release_failed_op()

        bool was_possibly_successful()
