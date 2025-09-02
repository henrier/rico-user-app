
import { ProductCategoryVO } from '../productcategory/data.d';

export namespace ProductCategoryAPI {

  /** 类目类型枚举值 */
  type CategoryTypesKey = 'IP' | 'LANGUAGE' | 'SERIES1' | 'SERIES2' | 'RECENTUPDATE';

  /** 类目类型枚举选项 */
  export const categoryTypesOptions = [
    { label: 'IP（一级）', value: 'IP' },
    { label: '语种（二级）', value: 'LANGUAGE' },
    { label: '系列1（三级）', value: 'SERIES1' },
    { label: '系列2（四级）', value: 'SERIES2' },
    { label: '近期更新（标签）', value: 'RECENTUPDATE' }
  ];

  /** 名称 */
  export interface I18NStringVO {
    /** 中文 */
    chinese: string;
    /** 英文 */
    english: string;
    /** 日文 */
    japanese: string;
  }

  /** 商品类目详情视图 */
  export interface ProductCategoryVO {
    /** 主键 */
    id: string;
    /** 名称 */
    name: I18NStringVO;
    /** 图片 */
    images: string[];
    /** 类目类型 */
    categoryTypes: CategoryTypesKey[];
    /** 父类目 */
    parentCategories: ProductCategoryVO[];
    /** 审计信息 */
    auditMetadata: API.AuditMetadata;
  }

  /** 创建商品类目参数 */
  export interface CreateProductCategoryParams {
    /** 名称 */
    name: I18NStringVO;
  }

  /** 创建商品类目（全参数）参数 */
  export interface CreateProductCategoryWithAllFieldsParams {
    /** 名称 */
    name: I18NStringVO;
    /** 图片 */
    images?: string[];
    /** 类目类型 */
    categoryTypes?: CategoryTypesKey[];
    /** 父类目 */
    parentCategories?: string[];
  }

  /** 修改名称参数 */
  export interface UpdateProductCategoryNameParams {
    /** 名称 */
    name: I18NStringVO;
  }

  /** 修改图片参数 */
  export interface UpdateProductCategoryImagesParams {
    /** 图片 */
    images: string[];
  }

  /** 添加类目类型参数 */
  export interface AddProductCategoryCategoryTypesParams {
    /** 类目类型列表 */
    categoryTypes: CategoryTypesKey[];
  }

  /** 移除类目类型参数 */
  export interface RemoveProductCategoryCategoryTypesParams {
    /** 要移除的类目类型列表 */
    categoryTypes: CategoryTypesKey[];
  }

  /** 添加父类目参数 */
  export interface AddProductCategoryParentCategoriesParams {
    /** 父类目列表 */
    parentCategories: string[];
  }

  /** 移除父类目参数 */
  export interface RemoveProductCategoryParentCategoriesParams {
    /** 要移除的父类目列表 */
    parentCategories: string[];
  }

  /** 分页查询商品类目参数 */
  export interface ProductCategoryPageParams extends API.PageParams {
    /** 名称 - 中文 */
    nameChinese?: string;
    /** 名称 - 英文 */
    nameEnglish?: string;
    /** 名称 - 日文 */
    nameJapanese?: string;
    /** 图片 */
    images?: string[];
    /** 类目类型 */
    categoryTypes?: CategoryTypesKey[];
    /** 父类目 */
    parentCategories?: string[];
    
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