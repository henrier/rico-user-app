
import { ProductCategoryAPI } from '../productcategory/data';
import { CardEffectFieldsAPI } from '../cardeffectfields/data';

import { DynamicField } from '@/components/DynamicField/types';

export namespace ProductInfoAPI {

  /** 名称 */
  export interface I18NStringVO {
    /** 中文 */
    chinese: string;
    /** 英文 */
    english: string;
    /** 日文 */
    japanese: string;
  }

  /** 商品信息详情视图 */
  export interface ProductInfoVO {
    /** 主键 */
    id: string;
    /** 名称 */
    name: I18NStringVO;
    /** 编码 */
    code: string;
    /** 等级 */
    level: string;
    /** 所属类目 */
    categories: ProductCategoryAPI.ProductCategoryVO[];
    /** 卡牌效果模板 */
    cardEffectTemplate: CardEffectFieldsAPI.CardEffectFieldsVO;
    /** 卡牌效果 */
    cardEffects: DynamicField[];
    /** 图片 */
    images: string[];
    /** 审计信息 */
    auditMetadata: API.AuditMetadata;
  }

  /** 创建商品信息参数 */
  export interface CreateProductInfoParams {
    /** 名称 */
    name: I18NStringVO;
    /** 编码 */
    code: string;
  }

  /** 创建商品信息（全参数）参数 */
  export interface CreateProductInfoWithAllFieldsParams {
    /** 名称 */
    name: I18NStringVO;
    /** 编码 */
    code: string;
    /** 等级 */
    level?: string;
    /** 所属类目 */
    categories?: string[];
    /** 卡牌效果模板 */
    cardEffectTemplate?: string;
    /** 卡牌效果 */
    cardEffects?: DynamicField[];
    /** 图片 */
    images?: string[];
  }

  /** 修改名称参数 */
  export interface UpdateProductInfoNameParams {
    /** 名称 */
    name: I18NStringVO;
  }

  /** 修改编码参数 */
  export interface UpdateProductInfoCodeParams {
    /** 编码 */
    code: string;
  }

  /** 修改等级参数 */
  export interface UpdateProductInfoLevelParams {
    /** 等级 */
    level: string;
  }

  /** 修改卡牌效果模板参数 */
  export interface UpdateProductInfoCardEffectTemplateParams {
    /** 卡牌效果模板 */
    cardEffectTemplate: string;
  }

  /** 修改卡牌效果参数 */
  export interface UpdateProductInfoCardEffectsParams {
    /** 卡牌效果 */
    cardEffects: DynamicField[];
  }

  /** 修改图片参数 */
  export interface UpdateProductInfoImagesParams {
    /** 图片 */
    images: string[];
  }

  /** 添加所属类目参数 */
  export interface AddProductInfoCategoriesParams {
    /** 所属类目列表 */
    categories: string[];
  }

  /** 移除所属类目参数 */
  export interface RemoveProductInfoCategoriesParams {
    /** 要移除的所属类目列表 */
    categories: string[];
  }

  /** 分页查询商品信息参数 */
  export interface ProductInfoPageParams extends API.PageParams {
    /** 名称 - 中文 */
    nameChinese?: string;
    /** 名称 - 英文 */
    nameEnglish?: string;
    /** 名称 - 日文 */
    nameJapanese?: string;
    /** 编码 */
    code?: string;
    /** 等级 */
    level?: string;
    /** 所属类目 */
    categories?: string[];
    /** 卡牌效果模板 */
    cardEffectTemplate?: string;
    /** 字段名（模糊查询） */
    fieldName?: string;
    /** 字段类型 */
    fieldType?: string;
    /** 显示名称（模糊查询） */
    displayName?: string;
    /** 字段值（模糊查询） */
    fieldValue?: string;
    /** 图片 */
    images?: string[];
    
    /** 创建时间范围开始 */
    createdAtStart?: string;
    /** 创建时间范围结束 */
    createdAtEnd?: string;
    /** 更新时间范围开始 */
    updatedAtStart?: string;
    /** 更新时间范围结束 */
    updatedAtEnd?: string;
    /** 创建者（模糊查询） */
    createdBy?: string;
    /** 更新者（模糊查询） */
    updatedBy?: string;
  }

} 