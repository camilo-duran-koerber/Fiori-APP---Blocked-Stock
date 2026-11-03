@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Overview of Quality and Blocked Stock Inpsections'

@Metadata.ignorePropagatedAnnotations: true

define view entity ZQM_I_STOCK_INSP
  as select from           /SCWM/AQUA as Stock

    left outer join        QALS       as InspectionLot on Stock.INSPID = InspectionLot.LOT_GUID

    // Approved V1 assumption: each inspection lot has zero or one notification.
    left outer to one join QMEL       as Notification  on InspectionLot.PRUEFLOS = Notification.PRUEFLOS

{
  key Stock.GUID_PARENT        as ParentGuid,
  key Stock.GUID_STOCK         as StockGuid,

      Stock.LGNUM              as WarehouseNumber,
      Stock.LGTYP              as StorageType,
      Stock.LGPLA              as StorageBin,
      Stock.HUIDENT            as HandlingUnit,
      Stock.MATID              as ProductGuid,
      Stock.CHARG              as Batch,
      Stock.CAT                as StockType,
      Stock.QUAN               as Quantity,
      Stock.UNIT               as UnitOfMeasure,
      Stock.WDATU              as GoodsReceiptDateTime,
      Stock.INSPID             as InspectionId,
      Stock.INSPTYP            as InspectionIdType,
      Stock.FLGMOVE            as HandlingUnitIsMoving,

      InspectionLot.LOT_GUID   as InspectionLotGuid,
      InspectionLot.PRUEFLOS   as InspectionLotNumber,
      InspectionLot.ART        as InspectionType,
      InspectionLot.HERKUNFT   as InspectionLotOrigin,
      InspectionLot.WERK       as Plant,
      InspectionLot.MATNR      as Material,
      InspectionLot.CHARG      as InspectionLotBatch,
      InspectionLot.LIFNR      as Supplier,
      InspectionLot.KUNNR      as Customer,
      InspectionLot.ENSTEHDAT  as InspectionLotCreationDate,
      InspectionLot.ENTSTEZEIT as InspectionLotCreationTime,
      InspectionLot.KZSKIPLOT  as InspectionLotSkipped,
      InspectionLot.STAT35     as UsageDecisionMade,
      InspectionLot.STAT34     as StockPostingsCompleted,
      InspectionLot.STAT37     as InspectionLotBlockedArchiving,
      
      Notification.QMNUM       as NotificationNumber,
      Notification.QMART       as NotificationType,
      Notification.QMTXT       as NotificationShortText,
      Notification.PHASE       as NotificationPhase,
      Notification.KZLOESCH    as NotificationDeletionIndicator,
      Notification.ERDAT       as NotificationCreationDate,
      Notification.AEDAT       as NotificationChangeDate,
      Notification.MATNR       as NotificationMaterial,
      Notification.CHARG       as NotificationBatch,
      Notification.MAWERK      as NotificationPlant,

      case
        when Stock.INSPID is initial
          then 'NO_INSPECTION_REFERENCE'
        when InspectionLot.LOT_GUID is null
          then 'INSPECTION_NOT_FOUND'
        else 'INSPECTION_FOUND'
      end                      as InspectionLinkStatus,

      case
        when Notification.PRUEFLOS is null
          then 'NO_NOTIFICATION'
        when Notification.KZLOESCH is not initial
          then 'NOTIFICATION_DELETED'
        when Notification.PHASE = '4'
          then 'NOTIFICATION_CLOSED'
        else 'NOTIFICATION_FOUND'
      end                      as NotificationLinkStatus,

      case
        when Stock.INSPID is initial
          then 'WARNING'
        when InspectionLot.LOT_GUID is null
          then 'ERROR'
        when Notification.KZLOESCH is not initial
          then 'WARNING'
        else 'OK'
      end                      as DataConsistencyStatus
}