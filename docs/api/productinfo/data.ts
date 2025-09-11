
import { ProductCategoryAPI } from '../productcategory/data';
import { CardEffectFieldsAPI } from '../cardeffectfields/data';

import { DynamicField } from '@/components/DynamicField/types';

export namespace ProductInfoAPI {

  /** 卡片语言枚举值 */
  type CardLanguageKey = 'ZH' | 'EN' | 'FR' | 'JA';

  /** 卡片语言枚举选项 */
  export const cardLanguageOptions = [
    { label: '中', value: 'ZH' },
    { label: '英', value: 'EN' },
    { label: '法', value: 'FR' },
    { label: '日', value: 'JA' }
  ];

  /** 类型枚举值 */
  type TypeKey = 'RAW' | 'SEALED';

  /** 类型枚举选项 */
  export const typeOptions = [
    { label: '单卡', value: 'RAW' },
    { label: '原盒', value: 'SEALED' }
  ];

  /** 名称 */
  export type I18NStringVO = ProductCategoryAPI.I18NStringVO;

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
    /** 建议售价 */
    suggestedPrice: number;
    /** 卡片语言 */
    cardLanguage: CardLanguageKey;
    /** 类型 */
    type: TypeKey;
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
    /** 类型 */
    type: TypeKey;
  }

  /** 创建商品信息（全参数）参数 */
  export interface CreateProductInfoWithAllFieldsParams {
    /** 名称 */
    name: I18NStringVO;
    /** 编码 */
    code: string;
    /** 等级 */
    level?: string;
    /** 建议售价 */
    suggestedPrice?: number;
    /** 卡片语言 */
    cardLanguage?: CardLanguageKey;
    /** 类型 */
    type: TypeKey;
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

  /** 修改建议售价参数 */
  export interface UpdateProductInfoSuggestedPriceParams {
    /** 建议售价 */
    suggestedPrice: number;
  }

  /** 修改卡片语言参数 */
  export interface UpdateProductInfoCardLanguageParams {
    /** 卡片语言 */
    cardLanguage: CardLanguageKey;
  }

  /** 修改类型参数 */
  export interface UpdateProductInfoTypeParams {
    /** 类型 */
    type: TypeKey;
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
    /** 建议售价最小值 */
    minSuggestedPrice?: number;
    /** 建议售价最大值 */
    maxSuggestedPrice?: number;
    /** 卡片语言 */
    cardLanguage?: CardLanguageKey;
    /** 类型 */
    type?: TypeKey;
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