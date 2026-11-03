@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Overview of Quality and Blocked Stock Inpsections'

@Metadata.ignorePropagatedAnnotations: true

define view entity ZQM_I_STOCK_INSP
  as select from           /scwm/aqua as Stock

    left outer join        qals       as InspectionLot on Stock.inspid = InspectionLot.lot_guid

    // Approved V1 assumption: each inspection lot has zero or one notification.
    left outer to one join qmel       as Notification  on InspectionLot.prueflos = Notification.prueflos

{
  key Stock.guid_parent        as ParentGuid,
  key Stock.guid_stock         as StockGuid,

      Stock.lgnum              as WarehouseNumber,
      Stock.lgtyp              as StorageType,
      Stock.lgpla              as StorageBin,
      Stock.huident            as HandlingUnit,
      Stock.matid              as ProductGuid,
      Stock.charg              as Batch,
      Stock.cat                as StockType,

      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      Stock.quan               as Quantity,

      Stock.unit               as UnitOfMeasure,
      Stock.wdatu              as GoodsReceiptDateTime,
      Stock.inspid             as InspectionId,
      Stock.insptyp            as InspectionIdType,
      Stock.flgmove            as HandlingUnitIsMoving,

      InspectionLot.lot_guid   as InspectionLotGuid,
      InspectionLot.prueflos   as InspectionLotNumber,
      InspectionLot.art        as InspectionType,
      InspectionLot.herkunft   as InspectionLotOrigin,
      InspectionLot.werk       as Plant,
      InspectionLot.matnr      as Material,
      InspectionLot.charg      as InspectionLotBatch,
      InspectionLot.lifnr      as Supplier,
      InspectionLot.kunnr      as Customer,
      InspectionLot.enstehdat  as InspectionLotCreationDate,
      InspectionLot.entstezeit as InspectionLotCreationTime,
      InspectionLot.kzskiplot  as InspectionLotSkipped,
      InspectionLot.stat35     as UsageDecisionMade,
      InspectionLot.stat34     as StockPostingsCompleted,
      InspectionLot.stat37     as InspecLotBlockedArch,

      Notification.qmnum       as NotificationNumber,
      Notification.qmart       as NotificationType,
      Notification.qmtxt       as NotificationShortText,
      Notification.phase       as NotificationPhase,
      Notification.kzloesch    as NotificationDeletionIndicator,
      Notification.erdat       as NotificationCreationDate,
      Notification.aedat       as NotificationChangeDate,
      Notification.matnr       as NotificationMaterial,
      Notification.charg       as NotificationBatch,
      Notification.mawerk      as NotificationPlant,

      case
        when bintohex(Stock.inspid) = '00000000000000000000000000000000'
          then 'NO_INSPECTION_REFERENCE'
        when InspectionLot.lot_guid is null
          then 'INSPECTION_NOT_FOUND'
        else 'INSPECTION_FOUND'
      end                      as InspectionLinkStatus,

      case
        when Notification.prueflos is null
          then 'NO_NOTIFICATION'
        when Notification.kzloesch is not initial
          then 'NOTIFICATION_DELETED'
        when Notification.phase = '4'
          then 'NOTIFICATION_CLOSED'
        else 'NOTIFICATION_FOUND'
      end                      as NotificationLinkStatus,

      case
        when bintohex(Stock.inspid) = '00000000000000000000000000000000'
          then 'WARNING'
        when InspectionLot.lot_guid is null
          then 'ERROR'
        when Notification.kzloesch is not initial
          then 'WARNING'
        else 'OK'
      end                      as DataConsistencyStatus
}
